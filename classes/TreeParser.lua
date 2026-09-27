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
---@alias WALStats {records: integer, bytes: integer?, fpi: integer?, fpi_bytes: integer?, buffers_full: integer?}
---@alias WALTable {node: WALStats, tree: WALStats}
---@alias BufferStats {hit: integer, read: integer, dirtied: integer, written: integer, total: integer, io_read: number?, io_write: number?}
---@alias BufferTable {Local: BufferStats?, Shared: BufferStats?, Temp: BufferStats?, Total: BufferStats}

---@alias PlanFormat "text"|"json"|"xml"|"yaml"|"pg_treepaint"
---@alias PlanType "SELECT"|"INSERT"|"UPDATE"|"DELETE"

---@class DumpedPlan
---@field root DumpedNode
---@field format PlanFormat
---@field type PlanType
---@field nodeCount integer
---@field subplanCount integer
---@field timing {planning: number?, execution: number?}?
---@field buffers {planning: BufferTable?, total: BufferTable}?
---@field wal WALStats?
---@field settings table<string, string>?
---@field serialization table
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
---@field wal WALTable?
---@field buffers BufferTable?
---@field workers integer? Number of worker instances of this node
---@field workerDump? DumpedNode[]
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
	Gather = "Gather",
	GatherMerge = "Gather Merge",
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
	["quicksort"] = "quick",
	["top-N heapsort"] = "topn_heap",
}

local WorkerIgnoreFields = {
	["Actual Loops"] = true,
	["Actual Startup Time"] = "please",
	["Actual Total Time"] = "please",
	["Actual Rows"] = "please",

	["Shared Hit Blocks"] = true,
	["Shared Read Blocks"] = true,
	["Shared Dirtied Blocks"] = true,
	["Shared Written Blocks"] = true,
	["Local Hit Blocks"] = true,
	["Local Read Blocks"] = true,
	["Local Dirtied Blocks"] = true,
	["Local Written Blocks"] = true,
	["Temp Read Blocks"] = true,
	["Temp Written Blocks"] = true,

	["WAL Records"] = true,
	["WAL Bytes"] = true,
	["WAL FPI"] = true,
	["WAL FPI Bytes"] = true,
	["WAL Buffers Full"] = true,

	["I/O Read Time"] = true,
	["I/O Write Time"] = true,
	["Shared I/O Read Time"] = true,
	["Shared I/O Write Time"] = true,
	["Local I/O Read Time"] = true,
	["Local I/O Write Time"] = true,
	["Temp I/O Read Time"] = true,
	["Temp I/O Write Time"] = true,
}

-- declarations

---@type table<NodeType, NodeDumper>
local dumpers = {}

--#region node type dumpers

---@param _ PlanNode
---@param sink DumpedNode
local function gather_dump_timing(_, sink)
	if not sink.timing then
		return
	end

	local child = sink.children[1]
	local node_total_startup, node_total_total = sink.timing.tree.total[1], sink.timing.tree.total[2]

	node_total_startup = node_total_startup - child.timing.tree.total[1]
	node_total_total = node_total_total - child.timing.tree.total[2]

	local loops = sink.loop_count

	sink.timing.node = {
		single = {string.format("%.3f", node_total_startup / loops), string.format("%.3f", node_total_total / loops)},
		total = {string.format("%.3f", node_total_startup), string.format("%.3f", node_total_total)}
	}
end

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
		local node_total_startup, node_total_total = tonumber(sink.timing.tree.total[1]), tonumber(sink.timing.tree.total[2])

		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				local child_loops = child["Actual Loops"]
				if sink.workers then
					child_loops = child_loops / sink.workers
				end

				node_total_startup = node_total_startup - child["Actual Total Time"] * child_loops
				node_total_total = node_total_total - child["Actual Total Time"] * child_loops
			end
		end

		node_total_startup = math.max(node_total_startup --[[@as number]], 0)

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

dumpers[NodeType.Gather] = function (node_data, sink)
	gather_dump_timing(node_data, sink)
end

dumpers[NodeType.GatherMerge] = function (node_data, sink)
	dumpers[NodeType.Gather](node_data, sink)
end

dumpers[NodeType.Hash] = function (node_data, sink)
	sink.columns = node_data["Output"]
end

dumpers[NodeType.HashJoin] = function (node_data, sink)
	sink.join_on = string.match(node_data["Hash Cond"] or "", "%((.+)%)") or node_data["Hash Cond"]
end

dumpers[NodeType.IndexOnlyScan] = function(node_data, sink)
	dumpers[NodeType.IndexScan](node_data, sink)
end

dumpers[NodeType.IndexScan] = function(node_data, sink)
	scan(node_data, sink)
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

local function copy_table(src)
	local new_table = {}

	for key, value in pairs(src) do
		new_table[key] = value
	end

	return new_table
end

-- class

---@class TreeParser
---@field textParser TextParser
---@field queryParser NodeStringParser
---@field dump DumpedPlan
---@field workers integer?
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

	self.dump.format = plan.tp_format

	plan = plan[1] or plan

	self.dump.root = self:dumpNode(plan["Plan"])

	-- Query type

	if self.dump.root.type == "ModifyTable" then
		if self.dump.root.raw["Operation"] == "Insert" then
			self.dump.type = "INSERT"
		elseif self.dump.root.raw["Operation"] == "Update" then
			self.dump.type = "UPDATE"
		elseif self.dump.root.raw["Operation"] == "Delete" then
			self.dump.type = "DELETE"
		end
	end

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

	-- Plan Summary Buffers, io & wal

	if not plan["Plan"]["Subplan Name"] then
		plan["Plan"]["Subplan Name"] = "dummy"
		local plans = plan["Plan"]["Plans"]
		plan["Plan"]["Plans"] = nil

		self:dumpBuffers(plan["Plan"], {})
		self:dumpWAL(plan["Plan"], {})
		self:dumpIO(plan["Plan"], {})

		plan["Plan"]["Subplan Name"] = nil
		plan["Plan"]["Plans"] = plans
	end

	if plan["Planning"] then
		local sink = {}
		plan["Planning"]["Subplan Name"] = "dummy"
		self:dumpBuffers(plan["Planning"], sink)
		self:dumpIO(plan["Planning"], sink)
		plan["Planning"]["Subplan Name"] = nil

		if sink.buffers then
			self.dump.buffers.planning = sink.buffers
		end
	end

	-- Misc

	self.dump.identifier = plan["Query Identifier"]
	self.dump.settings = plan["Settings"]
	self.dump.serialization = plan["Serialization"]

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
		workers = self.workers,
		raw = node
	}

	self.dump.nodeCount = self.dump.nodeCount + 1

	if new_node.relationship == "InitPlan" or new_node.relationship == "SubPlan" or new_node.relationship == "Subquery" then
		self.dump.subplanCount = self.dump.subplanCount + 1
	end

	if node["Workers Launched"] then
		self.workers = node["Workers Launched"] + 1
	end

	self:dumpCosts(node, new_node)

	if node.Plans then
		new_node.children = self:dumpNodeList(node.Plans)
	end

	if node["Workers Launched"] then
		self.workers = nil
	end

	self:dumpTiming(node, new_node)
	self:dumpBuffers(node, new_node)
	self:dumpIO(node, new_node)
	self:dumpWAL(node, new_node)
	self:dumpWorkers(node, new_node)

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

	if self.workers then
		loops = loops / self.workers
	end
	sink.loop_count = loops

	local real_startup, real_total = node_data["Actual Startup Time"] * loops, node_data["Actual Total Time"] * loops

	local timing = {}

	if node_data.Plans then
		timing.tree = {
			single = {string.format("%.3f", node_data["Actual Startup Time"]), string.format("%.3f", node_data["Actual Total Time"])},
			total = {string.format("%.3f", real_startup), string.format("%.3f", real_total)}
		}

		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				local child_loops = child["Actual Loops"]
				if self.workers then
					child_loops = child_loops / self.workers
				end

				real_startup = real_startup - child["Actual Startup Time"] * child_loops
				real_total = real_total - child["Actual Total Time"] * child_loops
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
	local shared_sum = shared_hit + shared_read + shared_dirtied + shared_written

	local local_hit, local_read, local_dirtied, local_written =
		node_data["Local Hit Blocks"],
		node_data["Local Read Blocks"],
		node_data["Local Dirtied Blocks"],
		node_data["Local Written Blocks"]
	local local_sum = local_hit + local_read + local_dirtied + local_written

	local temp_read, temp_written =
		node_data["Temp Read Blocks"],
		node_data["Temp Written Blocks"]
	local temp_sum = temp_read and (temp_read + temp_written) or 0

	if node_data["Subplan Name"] and (shared_sum + local_sum + temp_sum > 0) then
		self.dump.buffers = self.dump.buffers or { total = {} }
		local total = self.dump.buffers.total

		if shared_sum > 0 then
			total.Shared = total.Shared or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Shared.hit = total.Shared.hit + shared_hit
			total.Shared.read = total.Shared.read + shared_read
			total.Shared.dirtied = total.Shared.dirtied + shared_dirtied
			total.Shared.written = total.Shared.written + shared_written
			total.Shared.total = total.Shared.total + shared_sum
		end

		if local_sum > 0 then
			total.Local = total.Local or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Local.hit = total.Local.hit + local_hit
			total.Local.read = total.Local.read + local_read
			total.Local.dirtied = total.Local.dirtied + local_dirtied
			total.Local.written = total.Local.written + local_written
			total.Local.total = total.Local.total + local_sum
		end

		if temp_sum > 0 then
			total.Temp = total.Temp or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

			total.Temp.read = total.Temp.read + temp_read
			total.Temp.written = total.Temp.written + temp_written
			total.Temp.total = total.Temp.total + temp_sum
		end

		total.Total = total.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

		total.Total.hit = total.Total.hit + shared_hit + local_hit
		total.Total.read = total.Total.read + shared_read + local_read + temp_read
		total.Total.dirtied = total.Total.dirtied + shared_dirtied + local_dirtied
		total.Total.written = total.Total.written + shared_written + local_written + temp_written
		total.Total.total = total.Total.total + shared_sum + local_sum + temp_sum
	end

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

				if temp_read then
					temp_read = temp_read - child["Temp Read Blocks"]
					temp_written = temp_written - child["Temp Written Blocks"]
				end
			end
		end
	end

	shared_sum = shared_hit + shared_read + shared_dirtied + shared_written
	local_sum = local_hit + local_read + local_dirtied + local_written
	temp_sum = temp_read and (temp_read + temp_written) or 0

	if shared_sum > 0 then
		buffers.Shared = {hit = shared_hit, read = shared_read, dirtied = shared_dirtied, written = shared_written, total = shared_hit + shared_read + shared_dirtied + shared_written}
		buffers.Total = {hit = shared_hit, read = shared_read, dirtied = shared_dirtied, written = shared_written, total = shared_hit + shared_read + shared_dirtied + shared_written}
	end

	if local_sum > 0 then
		buffers.Local = {hit = local_hit, read = local_read, dirtied = local_dirtied, written = local_written, total = local_hit + local_read + local_dirtied + local_written}
		buffers.Total = buffers.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

		buffers.Total.hit = buffers.Total.hit + local_hit
		buffers.Total.read = buffers.Total.read + local_read
		buffers.Total.dirtied = buffers.Total.dirtied + local_dirtied
		buffers.Total.written = buffers.Total.written + local_written
		buffers.Total.total = buffers.Total.total + buffers.Local.total
	end

	if temp_sum > 0 then
		buffers.Temp = {hit = 0, read = temp_read, dirtied = 0, written = temp_written, total = temp_read + temp_written}
		buffers.Total = buffers.Total or {hit = 0, read = 0, dirtied = 0, written = 0, total = 0}

		buffers.Total.read = buffers.Total.read + temp_read
		buffers.Total.written = buffers.Total.written + temp_written
		buffers.Total.total = buffers.Total.total + buffers.Temp.total
	end

	sink.buffers = buffers
end

function TreeParser:dumpIO(node_data, sink)
	if not node_data["I/O Read Time"] and not node_data["Shared I/O Read Time"] then
		return
	end

	if not sink.buffers or not sink.buffers.Total then
		return
	end

	if node_data["Shared I/O Read Time"] then
		return self:dumpIODetailed(node_data, sink)
	end

	if node_data["I/O Read Time"] then
		return self:dumpIOCombined(node_data, sink)
	end
end

function TreeParser:dumpIOCombined(node_data, sink)
	local read, write = node_data["I/O Read Time"], node_data["I/O Write Time"]

	if node_data["Subplan Name"] then
		self.dump.buffers = self.dump.buffers or { total = { Total = {hit = 0, read = 0, dirtied = 0, written = 0, total = 0, io_read = 0, io_write = 0} } }
		local total = self.dump.buffers.total

		total.Total.io_read = total.Total.io_read and (total.Total.io_read + read) or read
		total.Total.io_write = total.Total.io_write and (total.Total.io_write + write) or write
	end

	if node_data.Plans then
		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				read = read - child["I/O Read Time"]
				write = write - child["I/O Write Time"]
			end
		end
	end

	sink.buffers.Total.io_read = read
	sink.buffers.Total.io_write = write
end

function TreeParser:dumpIODetailed(node_data, sink)
	local shared_read, shared_write, local_read, local_write, temp_read, temp_write = node_data["Shared I/O Read Time"], node_data["Shared I/O Write Time"], node_data["Local I/O Read Time"], node_data["Local I/O Write Time"], node_data["Temp I/O Read Time"], node_data["Temp I/O Write Time"]

	if node_data["Subplan Name"] then
		self.dump.buffers = self.dump.buffers or { total = { Total = {hit = 0, read = 0, dirtied = 0, written = 0, total = 0, io_read = 0, io_write = 0} } }
		local total = self.dump.buffers.total

		if total.Shared then
			total.Shared.io_read = total.Shared.io_read and (total.Shared.io_read + shared_read) or shared_read
			total.Shared.io_write = total.Shared.io_write and (total.Shared.io_write + shared_write) or shared_write
		end

		if total.Local then
			total.Local.io_read = total.Local.io_read and (total.Local.io_read + local_read) or local_read
			total.Local.io_write = total.Local.io_write and (total.Local.io_write + local_write) or local_write
		end

		if total.Temp then
			total.Temp.io_read = total.Temp.io_read and (total.Temp.io_read + temp_read) or temp_read
			total.Temp.io_write = total.Temp.io_write and (total.Temp.io_write + temp_write) or temp_write
		end

		if total.Total then
			local read_sum = shared_read + local_read + temp_read
			local write_sum = shared_write + local_write + temp_write

			total.Total.io_read = total.Total.io_read and (total.Total.io_read + read_sum) or read_sum
			total.Total.io_write = total.Total.io_write and (total.Total.io_write + write_sum) or write_sum
		end
	end

	if node_data.Plans then
		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				shared_read = shared_read - child["Shared I/O Read Time"]
				shared_write = shared_write - child["Shared I/O Write Time"]
				local_read = local_read - child["Local I/O Read Time"]
				local_write = local_write - child["Local I/O Write Time"]
				temp_read = temp_read - child["Temp I/O Read Time"]
				temp_write = temp_write - child["Temp I/O Write Time"]
			end
		end
	end

	local buffers = sink.buffers

	if not buffers then
		return
	end

	if buffers.Shared then
		buffers.Shared.io_read = shared_read
		buffers.Shared.io_write = shared_write
	end

	if buffers.Local then
		buffers.Local.io_read = local_read
		buffers.Local.io_write = local_write
	end

	if buffers.Temp then
		buffers.Temp.io_read = temp_read
		buffers.Temp.io_write = temp_write
	end

	if buffers.Total then
		buffers.Total.io_read = shared_read + local_read + temp_read
		buffers.Total.io_write = shared_write + local_write + temp_write
	end
end

function TreeParser:dumpWAL(node_data, sink)
	if not node_data["WAL Records"] then
		return
	end

	local records, bytes, fpi, fpi_bytes, buffers = node_data["WAL Records"], node_data["WAL Bytes"], node_data["WAL FPI"], node_data["WAL FPI Bytes"], node_data["WAL Buffers Full"]

	if node_data["Subplan Name"] then
		self.dump.wal = self.dump.wal or { records = 0, bytes = 0, fpi = 0, fpi_bytes = 0, buffers_full = 0 }

		self.dump.wal.records = self.dump.wal.records + (records or 0)
		self.dump.wal.bytes = self.dump.wal.bytes + (bytes or 0)
		self.dump.wal.fpi = self.dump.wal.fpi + (fpi or 0)
		self.dump.wal.fpi_bytes = self.dump.wal.fpi_bytes + (fpi_bytes or 0)
		self.dump.wal.buffers_full = self.dump.wal.buffers_full + (buffers or 0)
	end

	local wal = {}

	if node_data.Plans then
		wal.tree = {
			records = records,
			bytes = bytes,
			fpi = fpi,
			fpi_bytes = fpi_bytes,
			buffers_full = buffers,
		}

		for _, child in ipairs(node_data.Plans) do
			if not child["Subplan Name"] then
				records = records and (records - (child["WAL Records"] or 0))
				bytes = bytes and (bytes - (child["WAL Bytes"] or 0))
				fpi = fpi and (fpi - (child["WAL FPI"] or 0))
				fpi_bytes = fpi_bytes and (fpi_bytes - (child["WAL FPI Bytes"] or 0))
				buffers = buffers and (buffers - (child["WAL Buffers Full"] or 0))
			end
		end
	end

	wal.node = {
		records = records,
		bytes = bytes,
		fpi = fpi,
		fpi_bytes = fpi_bytes,
		buffers_full = buffers,
	}

	sink.wal = wal
end

function TreeParser:dumpWorkers(node_data, sink)
	if not node_data["Workers"] or #node_data["Workers"] == 0 then
		return
	end

	local workers = {}

	local loops = node_data["Actual Loops"]
	local pool = {
		["Actual Loops"] = loops,

		["Actual Startup Time"] = loops and node_data["Actual Startup Time"] * loops,
		["Actual Total Time"] = loops and node_data["Actual Total Time"] * loops,
		["Actual Rows"] = loops and node_data["Actual Rows"] * loops,

		["Shared Hit Blocks"] = node_data["Shared Hit Blocks"],
		["Shared Read Blocks"] = node_data["Shared Read Blocks"],
		["Shared Dirtied Blocks"] = node_data["Shared Dirtied Blocks"],
		["Shared Written Blocks"] = node_data["Shared Written Blocks"],
		["Local Hit Blocks"] = node_data["Local Hit Blocks"],
		["Local Read Blocks"] = node_data["Local Read Blocks"],
		["Local Dirtied Blocks"] = node_data["Local Dirtied Blocks"],
		["Local Written Blocks"] = node_data["Local Written Blocks"],
		["Temp Read Blocks"] = node_data["Temp Read Blocks"],
		["Temp Written Blocks"] = node_data["Temp Written Blocks"],

		["WAL Records"] = node_data["WAL Records"],
		["WAL Bytes"] = node_data["WAL Bytes"],
		["WAL FPI"] = node_data["WAL FPI"],
		["WAL FPI Bytes"] = node_data["WAL FPI Bytes"],
		["WAL Buffers Full"] = node_data["WAL Buffers Full"],

		["I/O Read Time"] = node_data["I/O Read Time"],
		["I/O Write Time"] = node_data["I/O Write Time"],
		["Shared I/O Read Time"] = node_data["Shared I/O Read Time"],
		["Shared I/O Write Time"] = node_data["Shared I/O Write Time"],
		["Local I/O Read Time"] = node_data["Local I/O Read Time"],
		["Local I/O Write Time"] = node_data["Local I/O Write Time"],
		["Temp I/O Read Time"] = node_data["Temp I/O Read Time"],
		["Temp I/O Write Time"] = node_data["Temp I/O Write Time"],
	}

	local child_indices = {}

	if node_data["Plans"] then
		pool["Plans"] = {}

		for pi, child in ipairs(node_data["Plans"]) do
			if not child["Subplan Name"] then
				local child_i = #pool["Plans"]+1

				child_indices[pi] = child_i
				pool["Plans"][child_i] = copy_table(child)

				pool["Plans"][child_i]["Actual Startup Time"] = pool["Plans"][child_i]["Actual Startup Time"] and pool["Plans"][child_i]["Actual Startup Time"] * pool["Plans"][child_i]["Actual Loops"]
				pool["Plans"][child_i]["Actual Total Time"] = pool["Plans"][child_i]["Actual Total Time"] and pool["Plans"][child_i]["Actual Total Time"] * pool["Plans"][child_i]["Actual Loops"]
				pool["Plans"][child_i]["Actual Rows"] = pool["Plans"][child_i]["Actual Rows"] and pool["Plans"][child_i]["Actual Rows"] * pool["Plans"][child_i]["Actual Loops"]
			end
		end
	end

	local worker_count = self.workers
	self.workers = nil

	for i, worker in ipairs(node_data["Workers"]) do
		local worker_sink = {
			no = worker["Worker Number"]
		}

		if node_data["Plans"] then
			worker["Plans"] = {}

			for pi, child in ipairs(node_data["Plans"]) do
				if not child["Subplan Name"] then
					worker["Plans"][#worker["Plans"]+1] = child["Workers"][i]

					self:subtractWorker(pool["Plans"][child_indices[pi]], child["Workers"][i])
				end
			end
		end

		self:dumpTiming(worker, worker_sink)
		self:dumpBuffers(worker, worker_sink)
		self:dumpIO(worker, worker_sink)
		self:dumpWAL(worker, worker_sink)
		dumpers[node_data["Node Type"]](worker, worker_sink)

		self:subtractWorker(pool, worker)

		if node_data["Plans"] then
			worker["Plans"] = nil
		end

		for key, value in pairs(worker) do
			if not WorkerIgnoreFields[key] and key ~= "Worker Number" then
				worker_sink.other = worker_sink.other or {}
				worker_sink.other[key] = value
			end
		end

		workers[i] = worker_sink
	end

	local master_sink = {}
	self:dumpTiming(pool, master_sink)
	self:dumpBuffers(pool, master_sink)
	self:dumpWAL(pool, master_sink)
	dumpers[node_data["Node Type"]](pool, master_sink)
	workers[0] = master_sink

	self.workers = worker_count

	sink.workerDump = workers
end

function TreeParser:subtractWorker(node, worker)
	for key, please in pairs(WorkerIgnoreFields) do
		if node[key] and worker[key] then
			if type(please) == "boolean" then
				node[key] = node[key] - worker[key]
			else
				node[key] = node[key] - worker[key] * worker["Actual Loops"]
			end
		end
	end
end

--#endregion

--#region Explain format parsers

---@param json_string string
---@return table
function TreeParser:parseJSON(json_string)
	json_string = json_string:gsub("\n(%S)", "%1")

	local tree = json.decode(fix_data(json_string))

	-- 64-bit integer to string
	local plan = tree[1] or tree
	if type(plan["Query Identifier"]) == "number" then
		plan["Query Identifier"] = string.match(json_string, "\"Query Identifier\":%s*(%-?%d+),")
	end

	tree.tp_format = "json"
	return tree
end

---@param text string
---@return table?
function TreeParser:parseText(text)
	local success, tree = pcall(self.textParser.parse, self.textParser, text)

	if not success then
		print("Failed to parse plan data, error: " .. tostring(tree))
		return
	end

	print(json.encode(tree[1]["Plan"]))

	tree.tp_format = "text"
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