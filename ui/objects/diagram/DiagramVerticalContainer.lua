-- vertical

---@class DiagramVerticalContainer : DiagramContainer
---@field DiagramContainer DiagramContainer
---@field parent DiagramArea|DiagramContainer
---@field master DiagramNode
---@field slave DiagramNode|DiagramContainer
---@field collapseEllipsis DiagramEllipsis
local DiagramVerticalContainer = {
	name = "DiagramVerticalContainer",
	extends = "DiagramContainer",
	default = {
		growth = "vertical",
	},
}

-- vertical fnc

function DiagramVerticalContainer:add(...)
	self.DiagramContainer.add(self, ...)
	if #self.objects == 1 then
		self.master = self.objects[#self.objects] --[[@as DiagramNode]]
	elseif #self.objects == 2 then
		self.slave = self.objects[#self.objects]
	end
end

function DiagramVerticalContainer:click_left()
	self:toggleCollapse()
end

function DiagramVerticalContainer:generateLines()
	local line = {}

	line[1] = self.master.x + self.master.w/2
	line[2] = self.master.y + self.master.h
	line[3] = line[1]

	if self.slave:isDrawn() and self.slave.name == "DiagramHorizontalContainer" then
		line[4] = line[2] + self.layout.gap/2
	else
		line[4] = line[2] + self.layout.gap
	end

	self.cachedLines = {line}
end

function DiagramVerticalContainer:toggleCollapse()
	local collapse = self:getCollapseObject()

	local tx, ty = self.master:getTranslation()

	if collapse:isDrawn() then
		collapse:hide()
		self.slave:show()
	else
		collapse:show()
		if self.hl then
			collapse:hoverOn(0, 0)
		end

		self.slave:hide()
	end

	self:relayout()

	local new_tx, new_ty = self.master:getTranslation()

	self.diagram:moveRoot(tx - new_tx, ty - new_ty)

	self.diagram:refreshMinimap()
end

function DiagramVerticalContainer:getCollapseObject()
	if self.collapseEllipsis then
		return self.collapseEllipsis
	end

	self.collapseEllipsis = self:createChild "DiagramEllipsis" {}

	self.collapseEllipsis:hide()

	return self.collapseEllipsis
end

function DiagramVerticalContainer:isCollapsed()
	return self.collapseEllipsis and self.collapseEllipsis:isDrawn() or false
end

function DiagramVerticalContainer:getConnectionHl()
	return self.hl or (self.slave.name == "DiagramHorizontalContainer" and self.slave.hl) or (self.objects[3] and self.objects[3].draw and self.objects[3].hl)
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

function DiagramVerticalContainer:selectRelatives(node)
	if self.slave == node then
		self.selectMode = "parent"
		self:redraw()
		return {self}
	end

	local relatives = self.parent:selectRelatives(self)

	relatives[#relatives+1] = self
	self.selectMode = "child"

	if self.slave.name == "DiagramHorizontalContainer" then
		relatives[#relatives+1] = self.slave --[[@as DiagramHorizontalContainer]]
		self.slave.selectMode = "child"

		for _, child in ipairs(self.slave.objects) do
			if child.name == "DiagramSubplanContainer" then
				relatives[#relatives+1] = child --[[@as DiagramSubplanContainer]]
				child.selectMode = "child"
			end
		end
	end

	return relatives
end

return DiagramVerticalContainer