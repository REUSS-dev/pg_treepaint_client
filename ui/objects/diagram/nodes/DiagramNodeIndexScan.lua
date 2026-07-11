-- node

---@class DiagramNodeIndexScan : DiagramNodeIndexOnlyScan
local DiagramNodeIndexScan = {
	name = "DiagramNodeIndexScan",
	extends = "DiagramNodeIndexOnlyScan",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_SCAN
		}
	}
}

-- node fnc

function DiagramNodeIndexScan:new()
end

return DiagramNodeIndexScan