-- node

---@class PlanNodeGatherMerge : PlanNodeGather
local PlanNodeGatherMerge = {
	name = "PlanNodeGatherMerge",
	extends = "PlanNodeGather",
	default = {
		colors = {
			border = COLORS.NODE_GATHER_MERGE
		}
	}
}

-- node fnc

function PlanNodeGatherMerge:new()
end

return PlanNodeGatherMerge