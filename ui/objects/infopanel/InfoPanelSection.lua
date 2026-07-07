-- InfoPanelSection

---@class InfoPanelSection : CompositeObject
---@field CompositeObject CompositeObject
---@field divider CompositeObject
---@field contents CompositeObject
---@field collapseButton InfoPanelSectionCollapse
---@field font string
---@field fontS love.Font
---@field title string
local InfoPanelSection = {
	name = "InfoPanelSection",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"},
		{{"title"}, "title"},
	},
	default = {
		w = "fill",
		h = "hug",
		growth = "vertical",
		gap = 5,
		horizontal = "left",
		vertical = "top",
		r = 10,
		padding = {10, 8},
		color = COLORS.INFO_PANEL_ELEMENT,
	},

	sectionStates = {
		["Costs Info"] = false,
		["WAL Info"] = false,
		["Other"] = false
	}
}

function InfoPanelSection:paint(...)
	self:resolveState()
	self.CompositeObject.paint(self)
end

function InfoPanelSection:getContentsContainer()
	return self.contents
end

function InfoPanelSection:addTextProtected(prefix, value, greyed)
	if not value then
		return self
	end

	return self:addText(prefix .. value, greyed)
end

function InfoPanelSection:addText(text, greyed)
	self.contents:createChild "Label" {
		w = "fill",
		h = "hug",
		horizontal = "left",
		text = text,
		font = self.fontS,
		textColor = greyed and COLORS.NODE_TEXT_GREYED or COLORS.NODE_TEXT
	}

	return self
end

function InfoPanelSection:toggleCollapse()
	self.sectionStates[self.title] = not self.sectionStates[self.title]
	self:resolveState()
end

function InfoPanelSection:resolveState()
	if self.sectionStates[self.title] then
		self.contents:show()
		self.divider:show()
		self.collapseButton.icon:setStyle("ChevronDown")
	else
		self.contents:hide()
		self.divider:hide()
		self.collapseButton.icon:setStyle("ChevronLeft")
	end
end

function InfoPanelSection:new()
	local fontM = love.graphics.newFont(self.font, 20)
	self.fontS = love.graphics.newFont(self.font, 17)

	if self.sectionStates[self.title] == nil then
		self.sectionStates[self.title] = true
	end

	local top_container = self:createChild "Container" {
		growth = "horizontal",
		w = "fill"
	}

	top_container:createChild "Label" {
		text = self.title,
		font = fontM,
		w = "fill",
		horizontal = "left"
	}

	self.collapseButton = top_container:createChild "InfoPanelSectionCollapse" {
		w = 24,
		h = 24,
		r = 12,
		color = COLORS.INFO_PANEL_BUTTON
	}

	self.divider = self:createChild "Container" {
		w = "fill",
		padding = {0, 0, 25, 0}
	} : createChild "Container" {
		w = "fill",
		h = 1,
		color = COLORS.INFO_PANEL_DIVIDER
	}

	self.contents = self:createChild "Container" {
		w = "fill",
		gap = 2
	}
end

return InfoPanelSection