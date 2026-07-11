-- node

---@class DiagramNodeBitmapAnd : DiagramNode
local DiagramNodeBitmapAnd = {
	name = "DiagramNodeBitmapAnd",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_BITMAPAND
		}
	}
}

-- node fnc

function DiagramNodeBitmapAnd:new()
end

return DiagramNodeBitmapAnd