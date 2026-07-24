-- SectionCollapse

---@class SectionCollapse : Button
---@field Button Button
---@field icon Icon
---@field target ObjectUI
---@field invert boolean
---@field icon_closed string
---@field icon_open string
local SectionCollapse = {
	name = "SectionCollapse",
	extends = "Button",
	rules = {
		{{"target"}, "target"},
		{{"invert"}, "invert"},
	},
	default = {
		w = 24,
		h = 24,
		r = 12,
		padding = 0,
		color = COLORS.COLLAPSE_BUTTON,
		additionalColor = {0, 0, 0, 0},

		closed = false
	},
}

function SectionCollapse:paint()
	self:resolveState()
	self.Button.paint(self)
end

function SectionCollapse:resolveState()
	if self.target.isCollapsed --[[@as function?]] then ---@cast self +{target: {isCollapsed: function}}
		if self.target:isCollapsed() then
			self.icon:setStyle(self.icon_closed)
		else
			self.icon:setStyle(self.icon_open)
		end

		return
	end

	if self.target:isDrawn() then
		self.icon:setStyle(self.icon_open)
	else
		self.icon:setStyle(self.icon_closed)
	end
end

function SectionCollapse:action()
	if self.target.toggleCollapse --[[@as function?]] then ---@cast self +{target: {toggleCollapse: function}}
		self.target:toggleCollapse()
		return
	end

	if self.target:isDrawn() then
		self.target:hide()
		self.icon:setStyle(self.icon_closed)
	else
		self.target:show()
		self.icon:setStyle(self.icon_open)
	end
end

function SectionCollapse:new()
	assert(self.target, "Element \"target\" is required for a SectionCollapse object")
	self.border_flag = false

	self.icon_closed = self.invert and "ChevronRight" or "ChevronLeft"
	self.icon_open = "ChevronDown"

	self.objects = {}

	self.icon = self:createChild "Icon" {
		style = self.icon_open,
		color = COLORS.COLOR_ACCENT_1
	}
end

return SectionCollapse