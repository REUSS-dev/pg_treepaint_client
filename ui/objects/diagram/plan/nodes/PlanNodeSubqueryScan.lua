-- node

---@class PlanNodeSubqueryScan : PlanNodeSeqScan
---@field PlanNodeSeqScan PlanNodeSeqScan
---@field PlanNode PlanNode
local PlanNodeSubqueryScan = {
	name = "PlanNodeSubqueryScan",
	extends = "PlanNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_SUBQUERY_SCAN
		}
	}
}

-- node fnc

function PlanNodeSubqueryScan:new()
	self.titleContainer:addDescProtected("", self.node.raw["Alias"], true)
end

return PlanNodeSubqueryScan