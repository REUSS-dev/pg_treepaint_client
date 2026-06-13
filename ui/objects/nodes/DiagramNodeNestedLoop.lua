-- node

---@class DiagramNodeNestedLoop : DiagramNode
local DiagramNodeNestedLoop = {
	name = "DiagramNodeNestedLoop",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.5, 0.5, 1, 1}
		}
	}
}

-- node fnc

function DiagramNodeNestedLoop:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "JOIN on " .. self.node.join_on,
		textColor = {0.7, 0.7, 0.7, 1}
	}
end

return DiagramNodeNestedLoop