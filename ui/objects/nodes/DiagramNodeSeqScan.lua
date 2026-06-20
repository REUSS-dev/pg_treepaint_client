-- node

---@class DiagramNodeSeqScan : DiagramNode
local DiagramNodeSeqScan = {
	name = "DiagramNodeSeqScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_SEQ_SCAN
		}
	}
}

-- node fnc

function DiagramNodeSeqScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}
end

return DiagramNodeSeqScan