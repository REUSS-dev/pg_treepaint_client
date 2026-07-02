-- InfoPanelSectionCollapse

---@class InfoPanelSectionCollapse : Button
---@field parent {parent: InfoPanelSection}
---@field icon Icon
local InfoPanelSectionCollapse = {
	name = "InfoPanelSectionCollapse",
	extends = "Button",
	rules = {
	},
	default = {
		w = 20,
		h = 20,
		r = 10,
		padding = 0,
		color = COLORS.INFO_PANEL_ELEMENT,
		additionalColor = {0, 0, 0, 0}
	},
}

function InfoPanelSectionCollapse:action()
	self.parent.parent:toggleCollapse()

	if self.icon.style == "ChevronDown" then
		self.icon:setStyle("ChevronLeft")
	elseif self.icon.style == "ChevronLeft" then
		self.icon:setStyle("ChevronDown")
	end
end

function InfoPanelSectionCollapse:new()
	self.objects = {}

	self.icon = self:createChild "Icon" {
		style = "ChevronDown"
	}
end

return InfoPanelSectionCollapse