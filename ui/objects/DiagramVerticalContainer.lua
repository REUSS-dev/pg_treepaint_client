-- vertical
local vertical = {}

local composite = require("classes.CompositeObject")

-- documentation



-- config

vertical.name = "DiagramVerticalContainer"
vertical.aliases = {}
vertical.rules = {
    {"layout", {w = "hug", h = "hug", gap = 50}},
	{"palette", {additionalColor = {1, 1, 1, 1}}},
	{{"line_size", "lineSize"}, "lineSize", 2}
}

-- consts



-- vars



-- init



-- fnc



-- classes

---@class DiagramVerticalContainer : CompositeObject
---@field lineSize number
---@field cachedLine number[]
local DiagramVerticalContainer = {}
local DiagramVerticalContainer_meta = {__index = DiagramVerticalContainer}
setmetatable(DiagramVerticalContainer, {__index = composite.class}) -- Set parenthesis

-- vertical fnc

function DiagramVerticalContainer:paint()
	love.graphics.setLineWidth(self.lineSize)
	love.graphics.line(self:getLine())

	composite.class.paint(self)
end

function DiagramVerticalContainer:getLine()
	if self.cachedLine then
		return self.cachedLine
	end

	local line = {}

	line[1] = self.objects[1].x + self.objects[1].w/2
	line[2] = self.objects[1].y + self.objects[1].h
	line[3] = line[1]

	if self.objects[2].getLines then -- Second child is another DiagramContainer. To be made suck less after OOP rework 
		line[4] = line[2] + self.layout.gap/2
	else
		line[4] = line[2] + self.layout.gap
	end

	self.cachedLine = line

	return line
end

function vertical.new(prototype)
    local obj = composite.new(prototype)
    setmetatable(obj, DiagramVerticalContainer_meta)
	---@cast obj DiagramVerticalContainer

	obj:setGrowth("vertical")
	obj.border_flag = false

    return obj
end

vertical.class = DiagramVerticalContainer

return vertical