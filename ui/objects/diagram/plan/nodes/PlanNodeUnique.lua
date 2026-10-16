-- node

---@class PlanNodeUnique : PlanNode
local PlanNodeUnique = {
	name = "PlanNodeUnique",
	extends = "PlanNode",
	default = {
		colors = {
			border = COLORS.NODE_UNIQUE
		}
	}
}

-- node fnc

function PlanNodeUnique:new()
end

return PlanNodeUnique