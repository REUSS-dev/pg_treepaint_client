-- node

---@class PlanNodeIndexScan : PlanNodeIndexOnlyScan
local PlanNodeIndexScan = {
	name = "PlanNodeIndexScan",
	extends = "PlanNodeIndexOnlyScan",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_SCAN
		}
	}
}

-- node fnc

function PlanNodeIndexScan:new()
end

return PlanNodeIndexScan