-- node

---@class DiagramNodeIndexScan : DiagramNode
local DiagramNodeIndexScan = {
	name = "DiagramNodeIndexScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_SCAN
		}
	}
}

-- node fnc

function DiagramNodeIndexScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}

	if self.node.loop_count then
		self.contentsContainer:createChild "Label" {
			font = self.font,
			text = "Loops: " .. self.node.loop_count,
			textColor = self.text_color
		}
	end
end

return DiagramNodeIndexScan