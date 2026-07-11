-- node

---@class DiagramNodeNestedLoop : DiagramNode
local DiagramNodeNestedLoop = {
	name = "DiagramNodeNestedLoop",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_NESTED_LOOP
		}
	}
}

-- node fnc

function DiagramNodeNestedLoop:new()
	self.titleContainer:addDescProtected("JOIN on ", self.node.table, true)
end

return DiagramNodeNestedLoop