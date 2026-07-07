-- ui/objects/nodes/DiagramNodeIndexOnlyScan.lua

---@class DiagramNodeIndexOnlyScan : DiagramNode
---@field DiagramNodeSeqScan DiagramNodeSeqScan
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_ONLY_SCAN
		}
	}
}

function DiagramNodeIndexOnlyScan:populateInfo(covered)
	local sections = self.DiagramNodeSeqScan.populateInfo(self, covered)

	covered["Index Name"] = true
	covered["Scan Direction"] = true
	covered["Index Searches"] = true
	covered["Rows Removed by Index Recheck"] = true
	covered["Index Cond"] = true

	sections[#sections+1] = self:create "InfoPanelSection" { title = "Index Info" }
		:addTextProtected("Index: ", self.node.raw["Index Name"])
		:addTextProtected("Scan Direction: ", self.node.raw["Scan Direction"])
		:addTextProtected("Index Searches: ", self.node.raw["Index Searches"])
		:addTextProtected("Rows Removed by Recheck: ", self.node.raw["Rows Removed by Index Recheck"])
		:addTextProtected("Condition:\n", self.node.raw["Index Cond"])

	return sections
end

-- node fnc

function DiagramNodeIndexOnlyScan:new()
end

return DiagramNodeIndexOnlyScan


