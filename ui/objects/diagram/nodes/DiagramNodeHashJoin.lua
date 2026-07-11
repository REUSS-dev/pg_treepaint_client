-- node

---@class DiagramNodeHashJoin : DiagramNode
---@field DiagramNodeNestedLoop DiagramNodeNestedLoop
local DiagramNodeHashJoin = {
	name = "DiagramNodeHashJoin",
	extends = "DiagramNodeNestedLoop",
	default = {
		colors = {
			border = COLORS.NODE_HASH_JOIN
		}
	}
}

function DiagramNodeHashJoin:populateInfo(covered)
	local sections = self.DiagramNodeNestedLoop.populateInfo(self, covered)
	local join_info = sections[#sections]

	covered["Hash Cond"] = true

	join_info:addTextProtected("Hash condition: ", self.node.raw["Hash Cond"])

	return sections
end

-- node fnc

function DiagramNodeHashJoin:new()
	self.titleContainer:addDescProtected("on ", self.node.join_on, true)
end

return DiagramNodeHashJoin