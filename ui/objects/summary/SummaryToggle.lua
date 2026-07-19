-- SummaryToggle

---@class SummaryToggle : Button
---@field parent DiagramArea
---@field summary SummaryDock
---@field icon Icon
local SummaryToggle = {
	name = "SummaryToggle",
	extends = "Button",
	rules = {
		{{"summary"}, "summary"}
	},
	default = {
		w = 30,
		h = 75,
		padding = 0,
		static = true,

		color = COLORS.SUMMARY_FILL,
		additionalColor = {0, 0, 0, 0},
		textColor = COLORS.COLOR_ACCENT_1
	},
}

function SummaryToggle:action()
	if self.summary:isDrawn() then
		self.parent.summaryObject:hide()
		self.icon:setStyle("ChevronRight")
	else
		self.parent.summaryObject:show()
		self.icon:setStyle("ChevronLeft")
	end
end

function SummaryToggle:new()
	self.border_flag = false

	self.objects = {}

	self.icon = self:createChild "Icon" {
		style = "ChevronLeft",
		color = self.palette.text
	}
end

return SummaryToggle