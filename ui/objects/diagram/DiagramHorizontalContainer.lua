-- horizontal

-- class

---@class DiagramHorizontalContainer : DiagramContainer
---@field DiagramContainer DiagramContainer
---@field parent DiagramArea|DiagramVerticalContainer
---@field objects (DiagramNode|DiagramVerticalContainer)[]
---@field selectModeParentIndex integer
local DiagramHorizontalContainer = {
	name = "DiagramHorizontalContainer",
	extends = "DiagramContainer",
	default = {
		growth = "horizontal",
	},
}

-- horizontal fnc

function DiagramHorizontalContainer:paintLines()
	love.graphics.setLineWidth(self.lineSize)
	love.graphics.setColor(self.palette.border)

	if self:getConnectionHl() then
		love.graphics.setLineWidth(self.lineSize * self.hoverMultiplier)
		love.graphics.setColor(self.hoverColor)
	elseif self.selectMode then
		if self.selectMode == "child" then
			love.graphics.setColor(COLORS.CONNECTION_CHILD)
		end
	end

	local lines = self:getLines()

	for _, line in ipairs(lines) do
		love.graphics.line(line)
	end

	if not self.hl and self.selectMode == "parent" then
		love.graphics.setColor(COLORS.CONNECTION_PARENT)
		love.graphics.line(lines[self.selectModeParentIndex])

		local y = lines[#lines][2]
		love.graphics.line(self.w/2, y, lines[self.selectModeParentIndex][1], y)
	end
end

function DiagramHorizontalContainer:click(_, _, but)
	if but == 1 and self.parent.name == "DiagramVerticalContainer" then
		self.parent:toggleCollapse()
	end
end

function DiagramHorizontalContainer:generateLines()
	if not self.parent.name == "DiagramVerticalContainer" then
		self.cachedLines = {}
		return
	end

	local lines = {}

	for i, node in ipairs(self.objects) do
		local line = {}

		line[1] = node.x + node.w/2
		line[2] = -self.parent.layout.gap/2
		line[3] = line[1]
		line[4] = node.y

		lines[i] = line
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

function DiagramHorizontalContainer:getConnectionHl()
	return self.hl or (self.parent.name == "DiagramVerticalContainer" and self.parent.hl)
end

function DiagramHorizontalContainer:selectRelatives(node)
	local relatives = self.DiagramContainer.selectRelatives(self, node)

	for index, child in ipairs(self.objects) do
		if child == node then
			self.selectModeParentIndex = index
		end
	end

	return relatives
end

return DiagramHorizontalContainer