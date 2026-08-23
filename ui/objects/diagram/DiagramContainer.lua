-- horizontal

-- consts

local HOVER_RADIUS = 5
local HOVER_MULTIPLIER = 2

-- static

local currentSelect	---@type DiagramNode?

-- class

---@class DiagramContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field parent DiagramArea|DiagramContainer
---@field diagram DiagramArea
---@field objects (DiagramNode|DiagramContainer)[]
---@field hoverMultiplier number
---@field hoverRadius integer
---@field lineSize number
---@field cachedLines number[][]
---@field selectMode "parent"|"child"|nil
---@field linesColor ColorTable
local DiagramContainer = {
	name = "DiagramContainer",
	extends = "CompositeObject",
	rules = {
		{{"line_size", "lineSize"}, "lineSize"},
		{{"diagram"}, "diagram"}
	},
	default = {
		gap = 50,
		growth = "vertical",
		vertical = "top",
		additionalColor = COLORS.CONNECTION,
		lineSize = 2
	},

	linesColor = COLORS.CONNECTION,
	hoverColor = COLORS.CONNECTION_HOVER,

	hoverMultiplier = HOVER_MULTIPLIER,
	hoverRadius = HOVER_RADIUS,
	defaultCursor = "hand"
}

-- horizontal fnc

function DiagramContainer:checkHover(x, y)
	local hover_object = self.CompositeObject.checkHover(self, x, y)

	if hover_object then
		return hover_object
	end

	if currentSelect and currentSelect.parent:isInteractible() then
		local hl = currentSelect:checkHover(x, y)
		if hl then
			return hl
		end
	end

	local lines = self:getLines()
	local line = lines[#lines]

	if not line then
		return
	end

	local tx, ty = self:getTranslation()

	return x >= (tx + line[1] - self.hoverRadius) and x <= (tx + line[3] + self.hoverRadius) and y >= (ty + line[2] - self.hoverRadius) and y <= (ty + line[4] + self.hoverRadius) and self
end

function DiagramContainer:paintLines()
	love.graphics.setLineWidth(self.lineSize)
	love.graphics.setColor(self.linesColor)

	if self:getConnectionHl() then
		love.graphics.setLineWidth(self.lineSize * self.hoverMultiplier)
		love.graphics.setColor(self.hoverColor)
	elseif self.selectMode then
		if self.selectMode == "parent" then
			love.graphics.setColor(COLORS.CONNECTION_PARENT)
		elseif self.selectMode == "child" then
			love.graphics.setColor(COLORS.CONNECTION_CHILD)
		end
	end

	local lines = self:getLines()

	for _, line in ipairs(lines) do
		love.graphics.line(line)
	end
end

function DiagramContainer:paint()
	self:paintLines()

	self.CompositeObject.paint(self)
end

function DiagramContainer:resize(new_w, new_h, relayout)
	self.CompositeObject.resize(self, new_w, new_h, relayout)
	self.cachedLines = nil
end

function DiagramContainer:getLines()
	if not self.cachedLines then
		self:generateLines()
	end

	return self.cachedLines
end

function DiagramContainer:generateLines()
	self.cachedLines = {}
end

function DiagramContainer:getConnectionHl()
	return self.hl
end

function DiagramContainer:isCollapsed()
	return false
end

---@param _ DiagramContainer|DiagramNode
---@return DiagramContainer[]
function DiagramContainer:selectRelatives(_)
	local relatives = self.parent:selectRelatives(self)

	self.selectMode = "parent"
	relatives[#relatives+1] = self

	return relatives
end

function DiagramContainer:resetSelect()
	self.selectMode = nil
end

---@param node DiagramNode?
function DiagramContainer.setCurrentSelect(node)
	currentSelect = node
end

function DiagramContainer:new()
	self.border_flag = false
	self.selectTrail = false
end

return DiagramContainer