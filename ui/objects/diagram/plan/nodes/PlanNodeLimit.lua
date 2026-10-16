-- node

---@class PlanNodeLimit : PlanNode
local PlanNodeLimit = {
	name = "PlanNodeLimit",
	extends = "PlanNode",
	default = {
		colors = {
			border = COLORS.NODE_LIMIT
		}
	}
}

-- node fnc

function PlanNodeLimit:new()
end

return PlanNodeLimit