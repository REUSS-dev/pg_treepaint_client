-- classes/TreeParser.lua

local json = require("libs.json")

-- docs

---@alias PlanNode {["Node Type"]: NodeType, Plans: PlanNode[]}

---@alias NodeDumper fun(node_data: PlanNode, sink: DumpedNode)

---@class DumpedNode
---@field type NodeType
---@field children DumpedNode[]?
---@field startup_cost string
---@field total_cost string
---@field columns string[] Hash: Table columns hash are generated for
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
		type = node_type
	}

	local startup_cost, total_cost = node["Startup Cost"], node["Total Cost"]

	if node.Plans then
		new_node.children = dump_node_list(node.Plans)

		for _, child in ipairs(node.Plans) do
			startup_cost = startup_cost - child["Startup Cost"]
			total_cost = total_cost - child["Total Cost"]
		end

		startup_cost = math.max(0, startup_cost)
		total_cost = math.max(startup_cost, total_cost)
	end

	new_node.startup_cost = string.format("%.2f", startup_cost)
	new_node.total_cost = string.format("%.2f", total_cost)

	dumpers[node_type](node, new_node)

	return new_node
end

--#region node type dumpers

local function scan(node_data, sink)
	sink.table = node_data["Relation Name"]

	if node_data["Alias"] then
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
	sink.startup_cost = string.format("%.2f", node_data["Startup Cost"] - node_data.Plans[1]["Total Cost"])
	sink.total_cost = string.format("%.2f", node_data["Total Cost"] - node_data.Plans[1]["Total Cost"])

	if node_data["Sort Method"] then
		sink.sort_method = SortMethod[node_data["Sort Method"]] or node_data["Sort Method"]
	end
end

dumpers[NodeType.Unknown] = function(_, _)
end

setmetatable(dumpers, {__index = function(self) return self[NodeType.Unknown] end})

--#endregion

-- class

---@class TreeParser
local TreeParser = {}
TreeParser.__index = TreeParser

function TreeParser:parse(tree)
	local parsed = {}

	tree = json.decode(tree)

	local root = tree[1]["Plan"]

	parsed.root = dump_node(root)

	return parsed
end

function TreeParser:new()
	local new_parser = {}

	setmetatable(new_parser, TreeParser)

	return new_parser
end

setmetatable(TreeParser, {__call = TreeParser.new})

return TreeParser