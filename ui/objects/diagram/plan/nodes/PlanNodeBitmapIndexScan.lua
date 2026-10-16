-- node

---@class PlanNodeBitmapIndexScan : PlanNode
---@field PlanNodeIndexOnlyScan PlanNodeIndexOnlyScan
local PlanNodeBitmapIndexScan = {
	name = "PlanNodeBitmapIndexScan",
	extends = "PlanNodeIndexOnlyScan",
	default = {
		colors = {
			border = {0.6, 1, 1, 1}
		}
	}
}

function PlanNodeBitmapIndexScan:populateInfo(covered)
	local sections = self.PlanNodeIndexOnlyScan.populateInfo(self, covered)

	table.remove(sections, 1)

	return sections
end

-- node fnc

function PlanNodeBitmapIndexScan:new()
end

return PlanNodeBitmapIndexScan