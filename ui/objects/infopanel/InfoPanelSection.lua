-- InfoPanelSection

---@class InfoPanelSection : CompositeObject
---@field divider CompositeObject
---@field contents CompositeObject
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
		color = COLORS.INFO_PANEL_ELEMENT
	},
}

function InfoPanelSection:getContentsContainer()
	return self.contents
end

function InfoPanelSection:addTextProtected(prefix, value)
	if not value then
		return self
	end

	return self:addText(prefix .. value)
end

function InfoPanelSection:addText(text)
	self.contents:createChild "Label" {
		w = "fill",
		h = "hug",
		horizontal = "left",
		text = text,
		font = self.fontS,
		textColor = COLORS.NODE_TEXT
	}

	return self
end

function InfoPanelSection:toggleCollapse()
	if self.contents.draw then
		self.contents:hide()
		self.divider:hide()
	else
		self.contents:show()
		self.divider:show()
	end
end

function InfoPanelSection:new()
	local fontM = love.graphics.newFont(self.font, 20)

	self.fontS = love.graphics.newFont(self.font, 17)

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

	top_container:createChild "InfoPanelSectionCollapse" {
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