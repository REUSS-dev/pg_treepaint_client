-- horizontal

-- consts

local HOVER_RADIUS = 5
local HOVER_MULTIPLIER = 2

---@class DiagramVerticalContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field parent DiagramArea|DiagramHorizontalContainer|DiagramVerticalContainer
---@field objects {[1]: DiagramNode, [2]: DiagramNode|DiagramHorizontalContainer|DiagramVerticalContainer}
---@field lineSize number
---@field cachedLines number[][]
---@field collapseEllipsis CompositeObject
local DiagramVerticalContainer = {
	name = "DiagramVerticalContainer",
	extends = "CompositeObject",
	rules = {
		{{"line_size", "lineSize"}, "lineSize"}
	},
	default = {
		gap = 50,
		growth = "vertical",
		additionalColor = COLORS.CONNECTION,
		lineSize = 2
	},

	hoverColor = COLORS.CONNECTION_HOVER,
	defaultCursor = "hand"
}

-- horizontal fnc

function DiagramVerticalContainer:checkHover(x, y)
	local hover_object = self.CompositeObject.checkHover(self, x, y)

	if hover_object then
		return hover_object
	end

	local tx, ty = self:getTranslation()
	local line = self:getLine()

	return x >= (tx + line[1] - HOVER_RADIUS) and x <= (tx + line[3] + HOVER_RADIUS) and y >= (ty + line[2] - HOVER_RADIUS) and y <= (ty + line[4] + HOVER_RADIUS) and self
end

function DiagramVerticalContainer:paint()
	if self:getConnectionHl() then
		love.graphics.setLineWidth(self.lineSize * HOVER_MULTIPLIER)
		love.graphics.setColor(self.hoverColor)
	else
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.setColor(self.palette.border)
	end

	love.graphics.line(self:getLine())

	self.CompositeObject.paint(self)
end

function DiagramVerticalContainer:click(_, _, but)
	if but == 1 then
		self:toggleCollapse()
	end
end

function DiagramVerticalContainer:getLine()
	if self.cachedLine then
		return self.cachedLine
	end

	local line = {}

	line[1] = self.objects[1].x + self.objects[1].w/2
	line[2] = self.objects[1].y + self.objects[1].h
	line[3] = line[1]

	if self.objects[2]:isDrawn() and self.objects[2].name == "DiagramHorizontalContainer" then
		line[4] = line[2] + self.layout.gap/2
	else
		line[4] = line[2] + self.layout.gap
	end

	self.cachedLine = line

	return line
end

function DiagramVerticalContainer:toggleCollapse()
	local collapse = self:getCollapseObject()

	local tx, ty = self.objects[1]:getTranslation()

	if collapse:isDrawn() then
		collapse:hide()
		self.objects[2]:show()
	else
		collapse:show()
		if self.hl then
			collapse:hoverOn(0, 0)
		end

		self.objects[2]:hide()
	end

	self:relayout()

	local new_tx, new_ty = self.objects[1]:getTranslation()

	self:moveRoot(tx - new_tx, ty - new_ty)
end

function DiagramVerticalContainer:getCollapseObject()
	if self.collapseEllipsis then
		return self.collapseEllipsis
	end

	self.collapseEllipsis = self:createChild "DiagramEllipsis" {}

	self.collapseEllipsis:hide()

	return self.collapseEllipsis
end

function DiagramVerticalContainer:resize(new_w, new_h, relayout)
	self.CompositeObject.resize(self, new_w, new_h, relayout)
	self.cachedLine = nil
end

function DiagramVerticalContainer:getConnectionHl()
	return self.hl or (self.objects[2].name == "DiagramHorizontalContainer" and self.objects[2].hl) or (self.objects[3] and self.objects[3].draw and self.objects[3].hl)
end

function DiagramVerticalContainer:hoverOn(x, y)
	if self.objects[3] and self.objects[3].draw then
		self.objects[3]:hoverOn(x, y)
	end

	return self.CompositeObject.hoverOn(self, x, y)
end

function DiagramVerticalContainer:hoverOff(x, y)
	if self.objects[3] and self.objects[3].draw then
		self.objects[3]:hoverOff(x, y)
	end

	return self.CompositeObject.hoverOff(self, x, y)
end

function DiagramVerticalContainer:moveRoot(...)
	self.parent:moveRoot(...)
end

function DiagramVerticalContainer:renderNodeInfo(...)
	self.parent:renderNodeInfo(...)
end

function DiagramVerticalContainer:new()
	self.border_flag = false
end

return DiagramVerticalContainer