-- node

---@class DiagramNodeBitmapOr : DiagramNode
local DiagramNodeBitmapOr = {
	name = "DiagramNodeBitmapOr",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_BITMAPOR
		}
	}
}

-- node fnc

function DiagramNodeBitmapOr:new()
end

return DiagramNodeBitmapOr