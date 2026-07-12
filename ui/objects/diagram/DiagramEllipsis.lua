-- DiagramEllipsis

---@class DiagramEllipsis : CompositeObject
---@field parent DiagramVerticalContainer
---@field CompositeObject CompositeObject
---@field normalColor ColorTable
local DiagramEllipsis = {
	name = "DiagramEllipsis",
	extends = "CompositeObject",
	default = {
		color = COLORS.NODE_FILL,
		additionalColor = COLORS.CONNECTION,
		padding = {10, 5},
		r = 5,
		hover = true,

		font = "default 18"
	},

	defaultCursor = "hand",
	hoverColor = COLORS.CONNECTION_HOVER,
}

function DiagramEllipsis:click(_, _, but)
	if but == 1 then
		self.parent:toggleCollapse()
	end
end

function DiagramEllipsis:hoverOn(x, y)
	self.palette:setColor(3, self.hoverColor)

	return self.CompositeObject.hoverOn(self, x, y)
end

function DiagramEllipsis:hoverOff(x, y)
	self.palette:setColor(3, self.normalColor)

	return self.CompositeObject.hoverOff(self, x, y)
end

function DiagramEllipsis:new()
	self:createChild "Label" {
		text = "...",
		font = self.font
	}

	self.normalColor = self.palette[3]
end

return DiagramEllipsis