-- node

---@class DiagramNodeBitmapIndexScan : DiagramNode
---@field DiagramNodeIndexOnlyScan DiagramNodeIndexOnlyScan
local DiagramNodeBitmapIndexScan = {
	name = "DiagramNodeBitmapIndexScan",
	extends = "DiagramNodeIndexOnlyScan",
	default = {
		colors = {
			border = {0.6, 1, 1, 1}
		}
	}
}

function DiagramNodeBitmapIndexScan:populateInfo(covered)
	local sections = self.DiagramNodeIndexOnlyScan.populateInfo(self, covered)

	table.remove(sections, 1)

	return sections
end

-- node fnc

function DiagramNodeBitmapIndexScan:new()
end

return DiagramNodeBitmapIndexScan