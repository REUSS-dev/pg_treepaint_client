-- node

---@class DiagramNodeBitmapHeapScan : DiagramNode
local DiagramNodeBitmapHeapScan = {
	name = "DiagramNodeBitmapHeapScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.25, 1, 1, 1}
		}
	}
}

-- node fnc

function DiagramNodeBitmapHeapScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = {0.8, 0.8, 0.8, 1}
	}
end

return DiagramNodeBitmapHeapScan