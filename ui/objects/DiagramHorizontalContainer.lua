-- horizontal
local horizontal = {}

local composite = require("classes.CompositeObject")

-- documentation



-- config

horizontal.name = "DiagramHorizontalContainer"
horizontal.aliases = {}
horizontal.rules = {
    {"layout", {w = "hug", h = "hug", gap = 50, vertical = "top"}},
	{"palette", {additionalColor = {1, 1, 1, 1}}},
	{{"line_size", "lineSize"}, "lineSize", 2}
}

-- consts



-- vars



-- init



-- fnc



-- classes

---@class DiagramHorizontalContainer : CompositeObject
---@field lineSize number
---@field cachedLines number[][]
local DiagramHorizontalContainer = {}
local DiagramHorizontalContainer_meta = {__index = DiagramHorizontalContainer}
setmetatable(DiagramHorizontalContainer, {__index = composite.class}) -- Set parenthesis

-- horizontal fnc

function DiagramHorizontalContainer:paint()
	love.graphics.setLineWidth(self.lineSize)

	for _, line in ipairs(self:getLines()) do
		love.graphics.line(line)
	end

	composite.class.paint(self)
end

function DiagramHorizontalContainer:getLines()
	if self.cachedLines then
		return self.cachedLines
	end

	if not self.parent.getLine then
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

function horizontal.new(prototype)
    local obj = composite.new(prototype)
    setmetatable(obj, DiagramHorizontalContainer_meta)
	---@cast obj DiagramHorizontalContainer

	obj:setGrowth("horizontal")
	obj.border_flag = false

    return obj
end

horizontal.class = DiagramHorizontalContainer

return horizontal