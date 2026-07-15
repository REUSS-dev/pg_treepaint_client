-- ContainerSubplan

-- class

---@class DiagramSubplanContainer : DiagramContainer
---@field DiagramContainer DiagramContainer
---@field title string
---@field titleContainer CompositeObject
---@field divider CompositeObject
---@field subplanContainer CompositeObject
---@field node DiagramNode
local DiagramSubplanContainer = {
	name = "DiagramSubplanContainer",
	extends = "DiagramContainer",
	rules = {
		{{"title"}, "title"}
	},
	default = {
		gap = 0,
		r = 15,
		growth = "vertical",

		additionalColor = COLORS.CONNECTION,
		textColor = COLORS.NODE_TEXT,
		font = "default 18",

		borderSize = 1
	},

	hoverMultiplier = 1
}

-- horizontal fnc

function DiagramSubplanContainer:checkHover(x, y)
	local hover_object = self.DiagramContainer.checkHover(self, x, y)

	if hover_object then
		return hover_object
	end

	return self.ObjectUI.checkHover(self.titleContainer, x, y) and self
end

function DiagramSubplanContainer:getConnectionHl()
	return false
end

function DiagramSubplanContainer:hoverOn(...)
	self.titleContainer.objects[1].palette:setColor(1, COLORS.NODE_SELECT)

	return self.DiagramContainer.hoverOn(self, ...)
end

function DiagramSubplanContainer:hoverOff(...)
	self.titleContainer.objects[1].palette:setColor(1, COLORS.NODE_HOVER)

	return self.DiagramContainer.hoverOff(self, ...)
end

function DiagramSubplanContainer:click(_, _, but)
	if but == 1 then
		self:toggleCollapse()
	end
end

function DiagramSubplanContainer:toggleCollapse()
	local w = self.w

	self.cachedLines = nil

	if self.subplanContainer:isDrawn() then
		self.titleContainer.layout.w = self:getObjectClass("DiagramNode").default.w + 100
		self.titleContainer:relayout()
		self.subplanContainer:hide()
		self.divider:hide()
	else
		self.titleContainer.layout.w = "fill"
		self.titleContainer:relayout()
		self.subplanContainer:show()
		self.divider:show()
	end

	self:relayout()

	if w then self.diagram:moveRoot(w - self.w, 0) end

	self.diagram:refreshMinimap()
end

function DiagramSubplanContainer:isCollapsed()
	return not self.subplanContainer:isDrawn()
end

function DiagramSubplanContainer:generateLines()
	if not self.subplanContainer:isDrawn() then
		self.cachedLines = {}
		return
	end

	local x1 = self.objects[2].w / 2
	local y1 = self.objects[2].y
	local x2 = x1
	local y2 = self.objects[3].y + self.objects[3].objects[1].y

	self.cachedLines = {{x1, y1, x2, y2}}
end

function DiagramSubplanContainer:pack(packed)
	self.subplanContainer:add(packed)
	self.node = packed

	return self
end

function DiagramSubplanContainer:maybeCollapse()
	if self.node.name == "DiagramVerticalContainer" then ---@cast self +{node: DiagramVerticalContainer}
		self:toggleCollapse()
		self.node = self.node.master
	end
end

function DiagramSubplanContainer:masqueradeSubplanContainer()
	self.subplanContainer.name = "DiagramSubplanContainer"

	---@diagnostic disable-next-line: inject-field
	self.subplanContainer.selectRelatives = function (_, ...)
		return self:selectRelatives(...)
	end

	---@diagnostic disable-next-line: inject-field
	self.subplanContainer.isCollapsed = function ()
		return false
	end
end

function DiagramSubplanContainer:new()
	self.border_flag = true

	self.titleContainer = self:createChild "Container" { w = "fill", padding = 15, vertical = "center"}

	self.titleContainer:createChild "Container" { w = "fill", padding = {15, 5}, color = COLORS.NODE_HOVER, r = 10}
			:createChild "Label" {
				text = self.title,
				font = self.font,
				w = "fill",
				horizontal = "center",
				textColor = self.palette.text
			}

	self.divider = self:createChild "Container" {
		w = "fill",
		h = 1,
		color = COLORS.NODE_BORDER
	}

	self.subplanContainer = self:createChild "Container" { w = "hug", vertical = "top", padding = {50, 25, 50, 50}, gap = 50}

	self:masqueradeSubplanContainer()
end

return DiagramSubplanContainer