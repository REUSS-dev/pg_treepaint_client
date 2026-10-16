-- node

---@class PlanNodeHashJoin : PlanNode
---@field PlanNodeNestedLoop PlanNodeNestedLoop
local PlanNodeHashJoin = {
	name = "PlanNodeHashJoin",
	extends = "PlanNodeNestedLoop",
	default = {
		colors = {
			border = COLORS.NODE_HASH_JOIN
		}
	}
}

function PlanNodeHashJoin:populateInfo(covered)
	local sections = self.PlanNodeNestedLoop.populateInfo(self, covered)
	local join_info = sections[#sections]

	covered["Hash Cond"] = true

	join_info:addTextParametrized("node.HashJoin.section.condition", self.node.raw["Hash Cond"])

	return sections
end

-- node fnc

function PlanNodeHashJoin:new()
	self.titleContainer:addDescParametrized("node.HashJoin.on", self.node.join_on, true)
end

return PlanNodeHashJoin