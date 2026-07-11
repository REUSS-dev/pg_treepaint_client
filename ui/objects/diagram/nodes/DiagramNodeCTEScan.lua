-- node

---@class DiagramNodeCTEScan : DiagramNodeSeqScan
---@field DiagramNodeSeqScan DiagramNodeSeqScan
local DiagramNodeCTEScan = {
	name = "DiagramNodeCTEScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_CTE_SCAN
		}
	}
}

function DiagramNodeCTEScan:populateInfo(covered)
	local sections = self.DiagramNodeSeqScan.populateInfo(self, covered)

	covered["CTE Name"] = true

	sections[1]:addTextProtected("CTE Name: ", self.node.raw["CTE Name"])

	return sections
end

-- node fnc

function DiagramNodeCTEScan:new()
	self.titleContainer:addDescProtected("on CTE ", self.node.raw["CTE Name"] and (self.node.raw["CTE Name"] .. (self.node.raw["Alias"] and (" (" .. self.node.raw["Alias"] .. ")") or "")), true)
end

return DiagramNodeCTEScan