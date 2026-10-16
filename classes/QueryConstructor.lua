-- QueryConstructor

local QUERY_NODE_PREFIX = "QueryNode"

---@class QueryConstructor
---@field diagram DiagramArea
local QueryConstructor = {}
QueryConstructor.__index = QueryConstructor

---@param query_root Query
function QueryConstructor:generate(query_root)
    return self:packNode(query_root)
end

---@param node Query
function QueryConstructor:packNode(node)
	if not node.children then
		return self:makeNode(node)
	end

	---@type DiagramVerticalContainer
	local vetical_container = self:create "DiagramVerticalContainer" { diagram = self.diagram }

	local node_object = self:makeNode(node)
	vetical_container:add(node_object)

	local children_object = self:packNodeList(node.children)

	vetical_container:add(children_object)

	return vetical_container
end

---@param node_list Query[]
function QueryConstructor:packNodeList(node_list)
	if #node_list == 1 then
		return self:packChild(node_list[1])
	end

	---@type DiagramHorizontalContainer
	local horizontal_container  = self:create "DiagramHorizontalContainer" { diagram = self.diagram }

	for _, node in ipairs(node_list) do
		local node_object = self:packChild(node)
		horizontal_container:add(node_object)
	end

	return horizontal_container
end

---@param node Query
function QueryConstructor:packChild(node)
	local packed = self:packNode(node)

	return packed
end

---@param node Query
---@return PlanNode
function QueryConstructor:makeNode(node)
	local node_type_no_space = string.gsub(node.type, " ", "")

	local specific_node_descriptor = self:getObjectClass(QUERY_NODE_PREFIX .. node_type_no_space) or self:getObjectClass(QUERY_NODE_PREFIX)

	return specific_node_descriptor {
		node,
		diagram = self.diagram
	}
end

---@private
function QueryConstructor:create(...)
    return self.diagram:create(...)
end

---@private
function QueryConstructor:getObjectClass(...)
    return self.diagram:getObjectClass(...)
end

function QueryConstructor:new(diagram)
    assert(diagram and diagram.name == "DiagramArea", "DiagramArea object is required for QueryConstructor")

	local new_constructor = {
        diagram = diagram
    }

	setmetatable(new_constructor, QueryConstructor)

	return new_constructor
end

setmetatable(QueryConstructor, {__call = QueryConstructor.new})

return QueryConstructor