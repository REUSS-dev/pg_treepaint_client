-- horizontal

-- consts

local HOVER_RADIUS = 5
local HOVER_MULTIPLIER = 2

-- class

---@class DiagramHorizontalContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field lineSize number
---@field cachedLines number[][]
---@field parent DiagramArea|DiagramVerticalContainer
local DiagramHorizontalContainer = {
	name = "DiagramHorizontalContainer",
	extends = "CompositeObject",
	rules = {
		{{"line_size", "lineSize"}, "lineSize"}
	},
	default = {
		gap = 50,
		growth = "horizontal",
		vertical = "top",
		additionalColor = COLORS.CONNECTION,
		lineSize = 2
	},

	hoverColor = COLORS.CONNECTION_HOVER,
	defaultCursor = "hand"
}

-- horizontal fnc

function DiagramHorizontalContainer:checkHover(x, y)
	local hover_object = self.CompositeObject.checkHover(self, x, y)

	if hover_object then
		return hover_object
	end

	local tx, ty = self:getTranslation()
	local lines = self:getLines()
	local line = lines[#lines]

	return x >= (tx + line[1] - HOVER_RADIUS) and x <= (tx + line[3] + HOVER_RADIUS) and y >= (ty + line[2] - HOVER_RADIUS) and y <= (ty + line[4] + HOVER_RADIUS) and self
end

function DiagramHorizontalContainer:paint()
	if self:getConnectionHl() then
		love.graphics.setLineWidth(self.lineSize * HOVER_MULTIPLIER)
		love.graphics.setColor(self.hoverColor)
	else
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.setColor(self.palette.border)
	end

	for _, line in ipairs(self:getLines()) do
		love.graphics.line(line)
	end

	self.CompositeObject.paint(self)
end

function DiagramHorizontalContainer:click(_, _, but)
	if but == 1 and self.parent.name == "DiagramVerticalContainer" then
		self.parent:toggleCollapse()
	end
end

function DiagramHorizontalContainer:getLines()
	if self.cachedLines then
		return self.cachedLines
	end

	if not self.parent.name == "DiagramVerticalContainer" then
		self.cachedLines = {}
		return {}
	end

	local lines = {}

	for _, node in ipairs(self.objects) do
		local line = {}

		line[1] = node.x + node.w/2
		line[2] = -self.parent.layout.gap/2
		line[3] = line[1]
		line[4] = node.y

		lines[#lines+1] = line
	end

	local sumup_line = {
		[1] = lines[1][1],
		[2] = lines[1][2],
		[3] = lines[#lines][1],
		[4] = lines[#lines][2],
	}
	lines[#lines+1] = sumup_line

	self.cachedLines = lines

	return lines
end

function DiagramHorizontalContainer:resize(new_w, new_h, relayout)
	self.CompositeObject.resize(self, new_w, new_h, relayout)
	self.cachedLines = nil
end

function DiagramHorizontalContainer:getConnectionHl()
	return self.hl or (self.parent.name == "DiagramVerticalContainer" and self.parent.hl)
end

function DiagramHorizontalContainer:moveRoot(...)
	self.parent:moveRoot(...)
end

function DiagramHorizontalContainer:new()
	self.border_flag = false
end

return DiagramHorizontalContainer