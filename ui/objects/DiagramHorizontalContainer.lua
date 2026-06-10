-- horizontal

---@class DiagramHorizontalContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field lineSize number
---@field cachedLines number[][]
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
		additionalColor = {1, 1, 1, 1},
		lineSize = 2
	}
}

-- horizontal fnc

function DiagramHorizontalContainer:paint()
	love.graphics.setLineWidth(self.lineSize)

	for _, line in ipairs(self:getLines()) do
		love.graphics.line(line)
	end

	self.CompositeObject.paint(self)
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

function DiagramHorizontalContainer:new()
	self.border_flag = false
end

return DiagramHorizontalContainer