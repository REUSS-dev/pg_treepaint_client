-- QueryConstructor

local QUERY_NODE_PREFIX = "QueryNode"

---@class QueryConstructor
---@field diagram DiagramArea
local QueryConstructor = {}
QueryConstructor.__index = QueryConstructor

---@param root_node DumpedNode
function QueryConstructor:generate(root_node)
    return
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