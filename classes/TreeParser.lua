-- classes/TreeParser.lua

local json = require("libs.json")

local TreeNormalizer = require("classes.TreeNormalizer")
local NodeStringParser = require("classes.NodeStringParser")
local TextParser = require("classes.TextParser")

-- docs

---@alias PlanNode {["Node Type"]: NodeType, Plans: PlanNode[]}

---@alias NodeDumper fun(node_data: PlanNode, sink: DumpedNode)
---@alias TimingStats {single: {[1]: string, [2]: string}, total: {[1]: string, [2]: string}}
---@alias TimingTable {node: TimingStats, tree: TimingStats?}
---@alias BufferStats {hit: integer, read: integer, dirtied: integer, written: integer, total: integer}
---@alias BufferTable {Local: BufferStats?, Shared: BufferStats?, Temp: BufferStats?, Total: BufferStats?}

---@class DumpedPlan
---@field root DumpedNode
---@field type string
---@field nodeCount integer
---@field subplanCount integer
---@field timing {planning: number?, execution: number?}?
---@field buffers {planning: BufferTable?, total: BufferTable}?
---@field identifier string

---@class DumpedNode
---@field raw PlanNode
---@field type NodeType
---@field relationship string
---@field children DumpedNode[]?
---@field startup_cost string?
---@field total_cost string?
---@field rows integer?
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

-- declarations

---@type table<NodeType, NodeDumper>
local dumpers = {}

--#region node type dumpers

---Dumps costs information about Sort node, that has specific relationship between its startup_cost and total_cost of its children
---@param node_data PlanNode
---@param sink DumpedNode
local function sort_dump_indicators(node_data, sink)
	local cost_startup, cost_total = node_data["Startup Cost"], node_data["Total Cost"]

	if cost_startup then
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

	if sink.timing then
		local node_total_startup, node_total_total = sink.timing.tree.total[1], sink.timing.tree.total[2]

		for _, child in ipairs(sink.children) do
			if not child.subplan then
				node_total_startup = node_total_startup - (child.timing.tree or child.timing.node).total[2]
				node_total_total = node_total_total - (child.timing.tree or child.timing.node).total[2]
			end
		end

		local loops = sink.loop_count

		sink.timing.node = {
			single = {string.format("%.3f", node_total_startup / loops), string.format("%.3f", node_total_total / loops)},
			total = {string.format("%.3f", node_total_startup), string.format("%.3f", node_total_total)}
		}
	end
end

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
	sort_dump_indicators(node_data, sink)

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
	if data:sub(1, 1) ~= "[" or data:sub(-1, -1) == "]" then
		return data
	end

	return data .. "}" .. "]"
end

-- class

---@class TreeParser
---@field textParser TextParser
---@field queryParser NodeStringParser
---@field dump DumpedPlan
local TreeParser = {}
TreeParser.__index = TreeParser

---@param tree string
---@return DumpedPlan?
function TreeParser:parse(tree)
	local plan

	---@diagnostic disable-next-line: missing-fields
	self.dump = {
		type = "SELECT",
		nodeCount = 0,
		subplanCount = 0,
	}

	tree = self.normalizer:normalize(tree)

	local _, _, nonspace = string.find(tree, "(%S)")

	if nonspace == "[" or nonspace == "{" then
		plan = self:parseJSON(tree)
	else
		plan = self:parseText(tree)
	end

	if not plan then
		return nil
	end

	plan = plan[1] or plan

	self.dump.root = self:dumpNode(plan["Plan"])

	-- Query type

	if self.dump.root.type == "Insert" then
		self.dump.type = "INSERT"
	elseif self.dump.root.type == "Update" then
		self.dump.type = "UPDATE"
	elseif self.dump.root.type == "Delete" then
		self.dump.type = "DELETE"
	end

	-- Plan Summary Timing

	if plan["Execution Time"] or plan["Planning Time"] then
		self.dump.timing = {
			planning = plan["Planning Time"],
			execution = plan["Execution Time"]
		}
	end

	-- Plan Summary Buffers

	if not plan["Plan"]["Subplan Name"] then
		plan["Plan"]["Subplan Name"] = "dummy"
		local plans = plan["Plan"]["Plans"]
		plan["Plan"]["Plans"] = nil

		self:dumpBuffers(plan["Plan"], {})

		plan["Plan"]["Subplan Name"] = nil
		plan["Plan"]["Plans"] = plans
	end

	if plan["Planning"] then
		local sink = {}
		plan["Planning"]["Subplan Name"] = "dummy"
		self:dumpBuffers(plan["Planning"], sink)
		plan["Planning"]["Subplan Name"] = nil

		self.dump.buffers.planning = sink.buffers
	end

	-- Misc

	self.dump.identifier = plan["Query Identifier"]

	return self.dump
end

--#region Plan processing

---Converts PlanNode of arbitrary type into DumpedNode
---@param node PlanNode
---@return DumpedNode
function TreeParser:dumpNode(node)
	local node_type = node["Node Type"]
	local new_node = {
		type = node_type,
		relationship = node["Parent Relationship"],
		subplan = node["Subplan Name"],
		raw = node
	}

	self.dump.nodeCount = self.dump.nodeCount + 1

	if new_node.relationship == "InitPlan" or new_node.relationship == "SubPlan" or new_node.relationship == "Subquery" then
		self.dump.subplanCount = self.dump.subplanCount + 1
	end

	self:dumpCosts(node, new_node)

	if node.Plans then
		new_node.children = self:dumpNodeList(node.Plans)
	end

	self:dumpTiming(node, new_node)
	self:dumpBuffers(node, new_node)

	dumpers[node_type](node, new_node)

	return new_node
end

---Converts list of PlanNode objects of arbitrary types into list of DumpedNode objects
---@param node_list PlanNode[]
---@return DumpedNode[]
function TreeParser:dumpNodeList(node_list)
	local dumped_nodes = {}

	for i, node in ipairs(node_list) do
		dumped_nodes[i] = self:dumpNode(node)
	end

	return dumped_nodes
end

---Dumps costs information about node
---@param node_data PlanNode
---@param sink DumpedNode
function TreeParser:dumpCosts(node_data, sink)
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

---Dumps analyze timing information about node
---@param node_data PlanNode
---@param sink DumpedNode
function TreeParser:dumpTiming(node_data, sink)
	local loops = node_data["Actual Loops"]

	if not loops then
		return
	end

	sink.rows = math.floor(node_data["Actual Rows"] * loops + .5)

	local real_startup, real_total = node_data["Actual Startup Time"] * loops, node_data["Actual Total Time"] * loops

	local timing = {}

	if node_data.Plans then
		timing.tree = {
			single = {string.format("%.3f", node_data["Actual Startup Time"]), string.format("%.3f", node_data["Actual Total Time"])},
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

function TreeParser:dumpBuffers(node_data, sink)
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
		node_data["Temp Read Blocks"],
		node_data["Temp Written Blocks"]

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

	if node_data["Subplan Name"] then
		self.dump.buffers = self.dump.buffers or { total = {} }
		local total = self.dump.buffers.total

		if buffers.Shared then
			total.Shared = total.Shared or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Shared.hit = total.Shared.hit + buffers.Shared.hit
			total.Shared.read = total.Shared.read + buffers.Shared.read
			total.Shared.dirtied = total.Shared.dirtied + buffers.Shared.dirtied
			total.Shared.written = total.Shared.written + buffers.Shared.written
			total.Shared.total = total.Shared.total + buffers.Shared.total
		end

		if buffers.Local then
			total.Local = total.Local or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Local.hit = total.Local.hit + buffers.Local.hit
			total.Local.read = total.Local.read + buffers.Local.read
			total.Local.dirtied = total.Local.dirtied + buffers.Local.dirtied
			total.Local.written = total.Local.written + buffers.Local.written
			total.Local.total = total.Local.total + buffers.Local.total
		end

		if buffers.Temp then
			total.Temp = total.Temp or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Temp.read = total.Temp.read + buffers.Temp.read
			total.Temp.written = total.Temp.written + buffers.Temp.written
			total.Temp.total = total.Temp.total + buffers.Temp.total
		end

		if buffers.Total then
			total.Total = total.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Total.hit = total.Total.hit + buffers.Total.hit
			total.Total.read = total.Total.read + buffers.Total.read
			total.Total.dirtied = total.Total.dirtied + buffers.Total.dirtied
			total.Total.written = total.Total.written + buffers.Total.written
			total.Total.total = total.Total.total + buffers.Total.total
		end
	end

	sink.buffers = buffers
end

--#endregion

--#region Explain format parsers

---@param json_string string
---@return DumpedPlan
function TreeParser:parseJSON(json_string)
	json_string = json_string:gsub("\n(%S)", "%1")

	local tree = json.decode(fix_data(json_string))

	-- 64-bit integer to string
	local plan = tree[1] or tree
	if type(plan["Query Identifier"]) == "number" then
		plan["Query Identifier"] = string.match(json_string, "\"Query Identifier\":%s*(%-?%d+),")
	end

	return tree
end

---@param text string
---@return DumpedPlan?
function TreeParser:parseText(text)
	local success, tree = pcall(self.textParser.parse, self.textParser, text)

	if not success then
		print("Failed to parse plan data, error: " .. tostring(tree))
		return
	end

	print(json.encode(tree[1]["Plan"]))

	return tree
end

--#endregion

function TreeParser:new()
	local new_parser = {}

	setmetatable(new_parser, TreeParser)

	self.normalizer = TreeNormalizer()
	self.queryParser = NodeStringParser()
	self.textParser = TextParser()

	return new_parser
end

setmetatable(TreeParser, {__call = TreeParser.new})

return TreeParser