-- SummaryInfoHead

---@class SummaryInfoHead : CompositeObject
---@field picture SummaryInfoPicture
---@field plan DumpedPlan
---@field nameLabel Label
---@field nodeCount Label
---@field subplanCount Label
---@field font {title: love.Font, text: love.Font}
local SummaryInfoHead = {
	name = "SummaryInfoHead",
	extends = "CompositeObject",
	rules = {
		{{"plan"}, "plan"}
	},
	default = {
		w = "fill",
		h = "hug",
		growth = "horizontal",
		gap = 10,
		horizontal = "left",
		vertical = "top",

		font = {title = "default 24", text = "default 16"}
	},
}

---Sets node info in head
---@param plan DumpedPlan
function SummaryInfoHead:setPlan(plan)
	-- 1 - picture
	self.picture:setPlan(plan)

	-- 2 - Type name
	self.nameLabel:setData(plan.type)

	self.nodeCount:setData(plan.nodeCount)

	self.subplanCount:setData(plan.subplanCount)
	if plan.subplanCount ~= 0 then
		self.subplanCount:show()
	else
		self.subplanCount:hide()
	end
end

function SummaryInfoHead:new()
	self.picture = self:createChild "SummaryInfoPicture" {
		w = 80,
		h = 80,
	}

	local text_container = self:createChild "Container" {
		w = "fill",
		h = "hug",
		growth = "vertical",
		horizontal = "left",
		vertical = "top",
		gap = 2,
		padding = {0, 3, 0, 0},
	}

	self.nameLabel = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.font.title,
		textColor = COLORS.NODE_TEXT,
		text = "summary.info.head.title"
	}

	self.nodeCount = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.font.text,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "summary.info.head.nodes"
	}

	self.subplanCount = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.font.text,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "summary.info.head.subplan"
	}
	self.subplanCount:hide()

	if self.plan then
		self:setPlan(self.plan)
	end
end

return SummaryInfoHead