-- classes/TreeParser.lua

local json = require("libs.json")

-- docs

---@alias PlanNode {["Node Type"]: NodeType, Plans: PlanNode[]}

---@alias NodeDumper fun(node: PlanNode): DumpedNode

---@class DumpedNode
---@field type NodeType
---@field children DumpedNode[]?

-- consts

---@enum NodeType
local NodeType = {
	Unknown = "Unknown"
}

-- fnc

---@type table<NodeType, NodeDumper>
local dumpers = {}

---Converts PlanNode of arbitrary type into DumpedNode
---@param node PlanNode
---@return DumpedNode
local function dump_node(node)
	local node_type = node["Node Type"]

	return dumpers[node_type](node)
end

---Converts list of PlanNode objects of arbitrary types into list of DumpedNode objects
---@param node_list PlanNode[]
---@return DumpedNode[]
local function dump_node_list(node_list)
	local dumped_nodes = {}

	for i, node in ipairs(node_list) do
		dumped_nodes[i] = dump_node(node)
	end

	return dumped_nodes
end

--#region node type dumpers

dumpers[NodeType.Unknown] = function(node)
	local new_node = {}
	new_node.type = node["Node Type"]

	if node["Plans"] then
		new_node.children = dump_node_list(node["Plans"])
	end

	return new_node
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