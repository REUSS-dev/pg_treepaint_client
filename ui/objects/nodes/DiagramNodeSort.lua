-- node

---@class DiagramNodeSort : DiagramNode
local DiagramNodeSort = {
	name = "DiagramNodeSort",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_SORT
		}
	}
}

-- node fnc

function DiagramNodeSort:new()
	if self.node.sort_method then
		self.titleContainer:createChild "Label" {
			font = self.desc_font,
			horizontal = "left",
			text = self.node.sort_method,
			textColor = self.text_color_desc
		}
	end

	if self.node.columns then
		self.contentsContainer:createChild "Label" {
			font = self.font,
			horizontal = "left",
			text = "by " .. table.concat(self.node.columns, ", "),
			textColor = self.text_color
		}
	end
end

return DiagramNodeSort