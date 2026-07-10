-- node

---@class DiagramNodeBitmapHeapScan : DiagramNode
local DiagramNodeBitmapHeapScan = {
	name = "DiagramNodeBitmapHeapScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_BITMAP_HEAP_SCAN
		}
	}
}

-- node fnc

function DiagramNodeBitmapHeapScan:new()
end

return DiagramNodeBitmapHeapScan