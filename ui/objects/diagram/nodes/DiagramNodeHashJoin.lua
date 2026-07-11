-- node

---@class DiagramNodeHashJoin : DiagramNode
local DiagramNodeHashJoin = {
	name = "DiagramNodeHashJoin",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_HASH_JOIN
		}
	}
}

-- node fnc

function DiagramNodeHashJoin:new()
	self.titleContainer:addDescProtected("on ", self.node.join_on, true)
end

return DiagramNodeHashJoin