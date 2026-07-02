-- node

---@class DiagramNodeBitmapHeapScan : DiagramNode
local DiagramNodeBitmapHeapScan = {
	name = "DiagramNodeBitmapHeapScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_BITMAP_HEAP_SCAN
		}
	}
}

-- node fnc

function DiagramNodeBitmapHeapScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}
end

return DiagramNodeBitmapHeapScan