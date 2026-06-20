-- horizontal

---@class DiagramVerticalContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field lineSize number
---@field cachedLines number[][]
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
	}
}

-- horizontal fnc

function DiagramVerticalContainer:paint()
	love.graphics.setLineWidth(self.lineSize)
	love.graphics.setColor(self.palette.border)
	love.graphics.line(self:getLine())

	self.CompositeObject.paint(self)
end

function DiagramVerticalContainer:getLine()
	if self.cachedLine then
		return self.cachedLine
	end

	local line = {}

	line[1] = self.objects[1].x + self.objects[1].w/2
	line[2] = self.objects[1].y + self.objects[1].h
	line[3] = line[1]

	if self.objects[2].name == "DiagramHorizontalContainer" then
		line[4] = line[2] + self.layout.gap/2
	else
		line[4] = line[2] + self.layout.gap
	end

	self.cachedLine = line

	return line
end

function DiagramVerticalContainer:new()
	self.border_flag = false
end

return DiagramVerticalContainer