-- InfoPanelPicture

local angelic = require("libs.angeliclove")

---@class InfoPanelPicture : CompositeObject
---@field angelicLabel Label
---@field font love.Font
---@field type string
local InfoPanelPicture = {
	name = "InfoPanelPicture",
	extends = "CompositeObject",
	rules = {
		{{"type"}, "type"}
	},
	default = {
		w = 80,
		h = 80,
		padding = 10,
		r = 10,
		color = COLORS.INFO_PANEL_ELEMENT,

		type = "A"
	},
}

---Updates node picture
---@param new_node DiagramNode
function InfoPanelPicture:setNode(new_node)
	self.type = assert(new_node and new_node.nodeType, "bad argument #1 to 'InfoPanelPicture:setType()' (DiagramNode expected, got " .. type(new_node) .. ")")

	self.angelicLabel.palette:setColor(2, {new_node.palette.border[1], new_node.palette.border[2], new_node.palette.border[3], 1})
	self.angelicLabel:setText(string.sub(self.type, 1, 1))
end

function InfoPanelPicture:new()
	self.font = angelic.new("automata", self.layout.h - self.layout.padding[2] - self.layout.padding[4]):getFont()

	self.angelicLabel = self:createChild "Label" {
		text = self.type,
		font = self.font,
		align = "center"
	}
end

return InfoPanelPicture