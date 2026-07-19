-- SummaryFold

local SLOPE = 0.85

---@class SummaryFold : CompositeObject
---@field Button Button
---@field parent SummaryFoldController
---@field content ObjectUI|string
---@field id integer
---@field first boolean
local SummaryFold = {
	name = "SummaryFold",
	extends = "Button",
	rules = {
		{{"content"}, "content"},
		{{"id"}, "id"},
		{{"first"}, "first"},
	},
	default = {
		w = "fill",
		h = "fill",
		growth = "horizontal",
		horizontal = "center",
		vertical = "center",

		color = COLORS.SUMMARY_INACTIVE,
		additionalColor = COLORS.SUMMARY_FILL,
		textColor = COLORS.SUMMARY_TEXT,
		font = "default 16",
		bsize = 3,

		content = "Fold",
		first = false
	},

	defaultCursor = "hand"
}

function SummaryFold:resize(...)
	self.Button.resize(self, ...)

	self.layout.padding[3] = math.floor(self.w * (1 - SLOPE) * 2 + .5)
	self:relayout()
end

function SummaryFold:paint()
	love.graphics.setColor(self.palette.main)

	if self.first then
		love.graphics.polygon("fill", 0, 0, 0, self.h, self.w, self.h, self.w * SLOPE, 0)
	else
		love.graphics.polygon("fill", -self.w * (1 - SLOPE), 0, 0, self.h, self.w, self.h, self.w * SLOPE, 0)
	end

	love.graphics.setLineWidth(self.bsize)
	love.graphics.setColor(self.palette.border)
	love.graphics.line(self.w * SLOPE - self.bsize + 1.25, 0, self.w - self.bsize + 1.25, self.h)

	return self.Button.paint(self)
end

function SummaryFold:action()
	self.parent:trigger(self.id)
end

function SummaryFold:new()
	assert(self.id, "Element \"id\" is required for a SummaryFold object")

	self.objects = {}
	self.fill_flag = false
	self.border_flag = false

	if type(self.content) == "string" then
		self:createChild "Label" {
			text = self.content,
			font = self.font,
			textColor = self.palette.text
		}
	end
end

return SummaryFold