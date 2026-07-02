-- ui/objects/nodes/DiagramNodeIndexOnlyScan.lua

---@class DiagramNodeIndexOnlyScan : DiagramNode
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_ONLY_SCAN
		}
	}
}

-- node fnc

function DiagramNodeIndexOnlyScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}
end

return DiagramNodeIndexOnlyScan


