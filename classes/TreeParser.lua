-- classes/TreeParser.lua

local json = require("libs.json")

local NodeStringParser = require("classes.NodeStringParser")
local TextParser = require("classes.TextParser")

-- docs

---@alias PlanNode {["Node Type"]: NodeType, Plans: PlanNode[]}

---@alias NodeDumper fun(node_data: PlanNode, sink: DumpedNode)
---@alias TimingStats {single: {[1]: string, [2]: string}, total: {[1]: string, [2]: string}}
---@alias TimingTable {node: TimingStats, tree: TimingStats?}
---@alias BufferStats {hit: integer, read: integer, dirtied: integer, written: integer, total: integer}
---@alias BufferTable {Local: BufferStats?, Shared: BufferStats?, Temp: BufferStats?, Total: BufferStats?}

---@class DumpedNode
---@field raw PlanNode
---@field type NodeType
---@field relationship string
---@field children DumpedNode[]?
---@field startup_cost string?
---@field total_cost string?
---@field timing TimingTable?
---@field buffers BufferTable?
---@field subplan string Subplans: Subplan name
---@field columns string[] Hash: Table columns hash are generated for / Sort: columns, resulted records are sorted against
---@field join_on string HashJoin: name of a join target table
---@field table string Scans: name of a scanned table
---@field loop_count integer Scans: Amount of loops through table/index
---@field sort_method SortMethod Sort: sort method

-- consts

---@enum NodeType
local NodeType = {
	Aggregate = "Aggregate",
	BitmapHeapScan = "Bitmap Heap Scan",
	BitmapIndexScan = "Bitmap Index Scan",
	Hash = "Hash",
	HashJoin = "Hash Join",
	IndexOnlyScan = "Index Only Scan",
	IndexScan = "Index Scan",
	NestedLoop = "Nested Loop",
	SeqScan = "Seq Scan",
	Sort = "Sort",

	Unknown = "Unknown"
}

---@enum SortMethod
local SortMethod = {
	["quicksort"] = "Quick sort",
	["top-N heapsort"] = "Top-N Heapsort",
}

-- fnc

local dump_node, dump_node_list
local dump_costs, dump_costs_sort, dump_timing, dump_buffers

---@type table<NodeType, NodeDumper>
local dumpers = {}

---Converts list of PlanNode objects of arbitrary types into list of DumpedNode objects
---@param node_list PlanNode[]
---@return DumpedNode[]
function dump_node_list(node_list)
	local dumped_nodes = {}

	for i, node in ipairs(node_list) do
		dumped_nodes[i] = dump_node(node)
	end

	return dumped_nodes
end

---Converts PlanNode of arbitrary type into DumpedNode
---@param node PlanNode
---@return DumpedNode
function dump_node(node)
	local node_type = node["Node Type"]
	local new_node = {
		type = node_type,
		relationship = node["Parent Relationship"],
		subplan = node["Subplan Name"],
		raw = node
	}

	dump_costs(node, new_node)

	if node.Plans then
		new_node.children = dump_node_list(node.Plans)
	end

	dump_timing(node, new_node)
	dump_buffers(node, new_node)

	dumpers[node_type](node, new_node)

	return new_node
end

---Dumps costs information about node
---@param node_data PlanNode
---@param sink DumpedNode
function dump_costs(node_data, sink)
	local cost_startup, cost_total = node_data["Startup Cost"], node_data["Total Cost"]

	if not cost_startup then
		return
	end

	if node_data.Plans then
		for _, child in ipairs(node_data.Plans) do
			cost_startup = cost_startup - child["Startup Cost"]
			cost_total = cost_total - child["Total Cost"]
		end

		cost_startup = math.max(0, cost_startup)
		cost_total = math.max(cost_startup, cost_total)
	end

	sink.startup_cost = string.format("%.2f", cost_startup)
	sink.total_cost = string.format("%.2f", cost_total)
end

---Dumps costs information about Sort node, that has specific relationship between its startup_cost and total_cost of its children
---@param node_data PlanNode
---@param sink DumpedNode
function dump_costs_sort(node_data, sink)
	local cost_startup, cost_total = node_data["Startup Cost"], node_data["Total Cost"]

	if not cost_startup then
		return
	end

	if node_data.Plans then
		for _, child in ipairs(node_data.Plans) do
			cost_startup = cost_startup - child["Total Cost"]
			cost_total = cost_total - child["Total Cost"]
		end

		cost_startup = math.max(0, cost_startup)
		cost_total = math.max(cost_startup, cost_total)
	end

	sink.startup_cost = string.format("%.2f", cost_startup)
	sink.total_cost = string.format("%.2f", cost_total)
end

---Dumps analyze timing information about node
---@param node_data PlanNode
---@param sink DumpedNode
function dump_timing(node_data, sink)
	local loops = node_data["Actual Loops"]

	if not loops then
		return
	end

	local real_startup, real_total = node_data["Actual Startup Time"] * loops, node_data["Actual Total Time"] * loops

	local timing = {}

	if node_data.Plans then
		timing.tree = {
			single = { string.format("%.3f", node_data["Actual Startup Time"]), string.format("%.3f", node_data["Actual Total Time"]) },
			total = {string.format("%.3f", real_startup), string.format("%.3f", real_total)}
		}

		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				real_startup = real_startup - child["Actual Startup Time"] * child["Actual Loops"]
				real_total = real_total - child["Actual Total Time"] * child["Actual Loops"]
			end
		end

		real_startup = math.max(0, real_startup)
		real_startup = math.min(real_startup, real_total)
	end

	timing.node = {
		single = {string.format("%.3f", real_startup / loops), string.format("%.3f", real_total / loops)},
		total = {string.format("%.3f", real_startup), string.format("%.3f", real_total)},
	}

	sink.timing = timing
end

function dump_buffers(node_data, sink)
	if not node_data["Shared Hit Blocks"] then
		return
	end

	local buffers = {}

	local shared_hit, shared_read, shared_dirtied, shared_written =
		node_data["Shared Hit Blocks"],
		node_data["Shared Read Blocks"],
		node_data["Shared Dirtied Blocks"],
		node_data["Shared Written Blocks"]

	local local_hit, local_read, local_dirtied, local_written =
		node_data["Local Hit Blocks"],
		node_data["Local Read Blocks"],
		node_data["Local Dirtied Blocks"],
		node_data["Local Written Blocks"]

	local temp_read, temp_written =
		node_data["Local Read Blocks"],
		node_data["Local Written Blocks"]

	if node_data.Plans then
		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				shared_hit = shared_hit - child["Shared Hit Blocks"]
				shared_read = shared_read - child["Shared Read Blocks"]
				shared_dirtied = shared_dirtied - child["Shared Dirtied Blocks"]
				shared_written = shared_written - child["Shared Written Blocks"]

				local_hit = local_hit - child["Local Hit Blocks"]
				local_read = local_read - child["Local Read Blocks"]
				local_dirtied = local_dirtied - child["Local Dirtied Blocks"]
				local_written = local_written - child["Local Written Blocks"]

				temp_read = temp_read - child["Temp Read Blocks"]
				temp_written = temp_written - child["Temp Written Blocks"]
			end
		end
	end

	if shared_hit ~= 0 or shared_read ~= 0 or shared_dirtied ~= 0 or shared_written ~= 0 then
		buffers.Shared = {hit = shared_hit, read = shared_read, dirtied = shared_dirtied, written = shared_written, total = shared_hit + shared_read + shared_dirtied + shared_written}
		buffers.Total = {hit = shared_hit, read = shared_read, dirtied = shared_dirtied, written = shared_written, total = shared_hit + shared_read + shared_dirtied + shared_written}
	end

	if local_hit ~= 0 or local_read ~= 0 or local_dirtied ~= 0 or local_written ~= 0 then
		buffers.Local = {hit = local_hit, read = local_read, dirtied = local_dirtied, written = local_written, total = local_hit + local_read + local_dirtied + local_written}
		buffers.Total = buffers.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

		buffers.Total.hit = buffers.Total.hit + local_hit
		buffers.Total.read = buffers.Total.read + local_read
		buffers.Total.dirtied = buffers.Total.dirtied + local_dirtied
		buffers.Total.written = buffers.Total.written + local_written
		buffers.Total.total = buffers.Total.total + buffers.Local.total
	end

	if temp_read ~= 0 or temp_written ~= 0 then
		buffers.Temp = {hit = 0, read = temp_read, dirtied = 0, written = temp_written, total = temp_read + temp_written}
		buffers.Total = buffers.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

		buffers.Total.read = buffers.Total.read + temp_read
		buffers.Total.written = buffers.Total.written + temp_written
		buffers.Total.total = buffers.Total.total + buffers.Temp.total
	end

	sink.buffers = buffers
end

--#region node type dumpers

local function scan(node_data, sink)
	sink.table = node_data["Relation Name"]

	if node_data["Alias"] and node_data["Alias"] ~= node_data["Relation Name"] then
		sink.table = sink.table .. " (" .. node_data["Alias"] .. ")"
	end
end

dumpers[NodeType.BitmapHeapScan] = function (node_data, sink)
	scan(node_data, sink)
end

dumpers[NodeType.Hash] = function (node_data, sink)
	sink.columns = node_data["Output"]
end

dumpers[NodeType.HashJoin] = function (node_data, sink)
	sink.join_on = string.match(node_data["Hash Cond"], "%((.+)%)") or node_data["Hash Cond"]
end

dumpers[NodeType.IndexOnlyScan] = function(node_data, sink)
	dumpers[NodeType.IndexScan](node_data, sink)
end

dumpers[NodeType.IndexScan] = function(node_data, sink)
	scan(node_data, sink)
	sink.loop_count = node_data["Actual Loops"] -- только с analyze, потом переделать
end

dumpers[NodeType.NestedLoop] = function(node_data, sink)
	sink.table = node_data.Plans[2]["Relation Name"]
end

dumpers[NodeType.SeqScan] = function (node_data, sink)
	scan(node_data, sink)
end

dumpers[NodeType.Sort] = function(node_data, sink)
	dump_costs_sort(node_data, sink)

	if node_data["Sort Method"] then
		sink.sort_method = SortMethod[node_data["Sort Method"]] or node_data["Sort Method"]
	end

	sink.columns = node_data["Sort Key"]
end

dumpers[NodeType.Unknown] = function(_, _)
end

setmetatable(dumpers, {__index = function(self) return self[NodeType.Unknown] end})

--#endregion

local function fix_data(data)
	if data:sub(-1, -1) == "]" then
		return data
	end

	return data .. "}" .. "]"
end

-- class

---@class TreeParser
---@field textParser TextParser
---@field queryParser NodeStringParser
local TreeParser = {}
TreeParser.__index = TreeParser

function TreeParser:parse(tree)
	tree = self:sanitizeData(tree)

	local _, _, nonspace = string.find(tree, "(%S)")

	if nonspace == "[" then
		return self:parseJSON(tree)
	end

	return self:parseText(tree)
end

function TreeParser:sanitizeData(data)
	data = string.gsub(data, "%s*%+\n", "\n")
	data = string.gsub(data, "\r", "")

	return data
end

function TreeParser:parseJSON(json_string)
	local parsed = {}

	json_string = json_string:gsub("\n(%S)", "%1")

	local tree = json.decode(fix_data(json_string))
	local root = tree[1]["Plan"]

	parsed.root = dump_node(root)

	return parsed
end

function TreeParser:parseText(text)
	local parsed = {}

	local success, tree = pcall(self.textParser.parse, self.textParser, text)

	if not success then
		print("Failed to parse plan data, error: " .. tostring(tree))
		return
	end

	local root = tree[1]["Plan"]

	print(json.encode(root))

	parsed.root = dump_node(root)

	return parsed
end

function TreeParser:new()
	local new_parser = {}

	setmetatable(new_parser, TreeParser)

	self.queryParser = NodeStringParser()

	self.textParser = TextParser()

	return new_parser
end

setmetatable(TreeParser, {__call = TreeParser.new})

return TreeParser