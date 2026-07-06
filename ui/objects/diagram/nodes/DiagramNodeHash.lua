-- node

---@class DiagramNodeHash : DiagramNode
local DiagramNodeHash = {
	name = "DiagramNodeHash",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_HASH
		}
	}
}

-- node fnc

function DiagramNodeHash:new()
	if self.node.columns then
		self.contentsContainer:createChild "Label" {
			w = "fill",
			font = self.font,
			horizontal = "left",
			text = "Columns",
			textColor = self.text_color
		}
	
		self.contentsContainer:createChild "Label" {
			w = "fill",
			font = self.desc_font,
			horizontal = "left",
			text = table.concat(self.node.columns, "\n"),
			textColor = self.text_color_desc
		}
	end
end

return DiagramNodeHash