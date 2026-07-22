-- SummaryInfoPicture

local angelic = require("libs.angeliclove")

---@enum QueryTypeColors
local QueryTypeColors = {
	SELECT = COLORS.QUERY_SELECT,
	INSERT = COLORS.QUERY_INSERT,
	UPDATE = COLORS.QUERY_UPDATE,
	DELETE = COLORS.QUERY_DELETE,
}

setmetatable(QueryTypeColors, { __index = function ()
	return {1, 1, 1, 1}
end })

---@class SummaryInfoPicture : CompositeObject
---@field angelicLabel Label
---@field type string
local SummaryInfoPicture = {
	name = "SummaryInfoPicture",
	extends = "CompositeObject",
	rules = {
		{{"type"}, "type"}
	},
	default = {
		w = 80,
		h = 80,
		padding = 10,
		r = 10,
		color = COLORS.COLOR_PRIMARY_2,

		type = "S"
	},
}

---Updates node picture
---@param plan DumpedPlan
function SummaryInfoPicture:setPlan(plan)
	self.type = assert(plan and plan.type, "bad argument #1 to 'SummaryInfoPicture:setPlan()' (DumpedPlan expected, got " .. type(plan) .. ")")

	self.angelicLabel.palette:setColor(2, QueryTypeColors[plan.type])
	self.angelicLabel:setText(string.sub(self.type, 1, 1))
end

function SummaryInfoPicture:new()
	self.font = angelic.new("automata", self.layout.h - self.layout.padding[2] - self.layout.padding[4]):getFont()

	self.angelicLabel = self:createChild "Label" {
		text = self.type,
		font = self.font,
		align = "center"
	}
end

return SummaryInfoPicture