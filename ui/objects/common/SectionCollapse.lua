-- SectionCollapse

---@class SectionCollapse : Button
---@field Button Button
---@field icon Icon
---@field target ObjectUI
local SectionCollapse = {
	name = "SectionCollapse",
	extends = "Button",
	rules = {
		{{"target"}, "target"}
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
			self.icon:setStyle("ChevronLeft")
		else
			self.icon:setStyle("ChevronDown")
		end

		return
	end

	if self.target:isDrawn() then
		self.icon:setStyle("ChevronDown")
	else
		self.icon:setStyle("ChevronLeft")
	end
end

function SectionCollapse:action()
	if self.target.toggleCollapse --[[@as function?]] then ---@cast self +{target: {toggleCollapse: function}}
		self.target:toggleCollapse()
		return
	end

	if self.target:isDrawn() then
		self.target:hide()
		self.icon:setStyle("ChevronLeft")
	else
		self.target:show()
		self.icon:setStyle("ChevronDown")
	end
end

function SectionCollapse:new()
	assert(self.target, "Element \"target\" is required for a SectionCollapse object")
	self.border_flag = false

	self.objects = {}

	self.icon = self:createChild "Icon" {
		style = "ChevronDown",
		color = COLORS.COLOR_ACCENT_1
	}
end

return SectionCollapse