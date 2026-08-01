-- SummaryFoldController

---@class SummaryFoldController : CompositeObject
---@field CompositeObject CompositeObject
---@field parent SummaryDock
---@field folds {[1]: string, [2]: ObjectUI|string}[]
---@field callbacks string[]
---@field current integer
local SummaryFoldController = {
	name = "SummaryFoldController",
	extends = "CompositeObject",
	rules = {
		{{"config", "folds", "pop"}, "folds"},
	},
	default = {
		w = "fill",
		h = 40,
		growth = "horizontal",
		gap = 0,
		horizontal = "left",
		vertical = "top",

		color = COLORS.SUMMARY_INACTIVE,
		additionalColor = COLORS.SUMMARY_FILL,
		textColor = COLORS.SUMMARY_TEXT,

		shear = true
	},
}

---@param folds {[1]: string, [2]: ObjectUI|string}[]
function SummaryFoldController:populate(folds)
	self.objects = {}

	for id, pair in ipairs(folds) do
		self.callbacks[id] = pair[1]

		self:createChild "SummaryFold" {
			w = "fill",
			content = pair[2],
			id = id,
			first = id == 1,

			color = self.palette.main,
			additionalColor = self.palette.border,
			textColor = self.palette.text
		}
	end
end

function SummaryFoldController:triggerDefault()
	self:trigger(1)
end

---@public
---@param id integer
function SummaryFoldController:trigger(id)
	id = id or self.current

	if not self.parent[self.callbacks[id]] then
		return
	end

	self.objects[self.current].originalColor = self.palette.main
	self.objects[self.current].palette:setColor(1, self.palette.main)
	self.objects[id].originalColor = self.palette.border
	self.objects[id].palette:setColor(1, self.palette.border)

	self.current = id
	self:redraw()

	self.parent[self.callbacks[id]](self.parent)
end

function SummaryFoldController:new()
	self.fill_flag = false
	self.border_flag = false

	self.callbacks = {}
	self.current = 1
end

return SummaryFoldController