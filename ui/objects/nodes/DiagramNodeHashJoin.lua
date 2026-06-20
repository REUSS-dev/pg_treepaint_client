-- node

---@class DiagramNodeHashJoin : DiagramNode
local DiagramNodeHashJoin = {
	name = "DiagramNodeHashJoin",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_HASH_JOIN
		}
	}
}

-- node fnc

function DiagramNodeHashJoin:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.join_on,
		textColor = self.text_color_desc
	}
end

return DiagramNodeHashJoin