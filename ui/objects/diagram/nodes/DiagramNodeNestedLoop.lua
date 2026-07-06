-- node

---@class DiagramNodeNestedLoop : DiagramNode
local DiagramNodeNestedLoop = {
	name = "DiagramNodeNestedLoop",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_NESTED_LOOP
		}
	}
}

-- node fnc

function DiagramNodeNestedLoop:new()

	if self.node.table then
		self.titleContainer:createChild "Label" {
			w = "fill",
			font = self.desc_font,
			horizontal = "left",
			text = "JOIN on " .. self.node.table,
			textColor = self.text_color_desc
		}
	end
end

return DiagramNodeNestedLoop