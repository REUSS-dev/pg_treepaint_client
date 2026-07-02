-- node

---@class DiagramNodeBitmapIndexScan : DiagramNode
local DiagramNodeBitmapIndexScan = {
	name = "DiagramNodeBitmapIndexScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.6, 1, 1, 1}
		}
	}
}

-- node fnc

function DiagramNodeBitmapIndexScan:new()
end

return DiagramNodeBitmapIndexScan