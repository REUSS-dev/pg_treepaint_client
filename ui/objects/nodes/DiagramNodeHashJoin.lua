-- node

---@class DiagramNodeHashJoin : DiagramNode
local DiagramNodeHashJoin = {
	name = "DiagramNodeHashJoin",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.5, 0, 0.5, 1}
		}
	}
}

-- node fnc

function DiagramNodeHashJoin:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.join_on,
		textColor = {0.8, 0.8, 0.8, 1}
	}
end

return DiagramNodeHashJoin