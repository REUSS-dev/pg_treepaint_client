-- SummaryDock

-- Folds contents

local folds = {
	{"triggerInfo", "Info"},
	{"triggerSubplans", "Subplans"},
	{"triggerStats", "Stats"},
	{"triggerInsights", "Insights"},
}

---@class SummaryDock : CompositeObject
---@field CompositeObject CompositeObject
---@field diagram DiagramArea
---@field plan DumpedPlan
---@field folds SummaryFoldController
---@field contentsContainer CompositeObject
---@field content ObjectUI[][]
---@field currentContent integer
local SummaryDock = {
	name = "SummaryDock",
	extends = "CompositeObject",
	rules = {
		{{"diagram"}, "diagram"},
		{{"plan"}, "plan"},
	},
	default = {
		w = 400,
		h = "fill",
		growth = "vertical",
		gap = 0,
		vertical = "top",

		color = COLORS.SUMMARY_FILL,
		textColor = COLORS.COLOR_TEXT_1
	},
}

function SummaryDock:applyPlan(new_plan)
	self.plan = new_plan

	self:generateContent()
	self.folds:trigger()
	self:show()
end

--#region Button triggers

function SummaryDock:triggerInfo()
	if not self.content then
		return
	end

	if self.currentContent == 1 then
		return
	end

	self.currentContent = 1

	self.contentsContainer.objects = self.content[1]
	self:relayout()
end

function SummaryDock:triggerSubplans()
	if not self.content then
		return
	end

	if self.currentContent == 2 then
		return
	end

	self.currentContent = 2

	self.contentsContainer.objects = self.content[2]
	self:relayout()
end

function SummaryDock:triggerStats()
	if not self.content then
		return
	end

	if self.currentContent == 3 then
		return
	end

	self.currentContent = 3

	self.contentsContainer.objects = self.content[3]
	self:relayout()
end

function SummaryDock:triggerInsights()
	if not self.content then
		return
	end

	if self.currentContent == 4 then
		return
	end

	self.currentContent = 4

	self.contentsContainer.objects = self.content[4]
	self:relayout()
end

--#endregion

function SummaryDock:generateContent()
	self.content = {}

	self.content[1] = self:generateInfo()
	self.content[2] = self:generateSubplans()
	self.content[3] = self:generateStats()
	self.content[4] = self:generateInsights()
end

function SummaryDock:generateInfo()
	local content = {}

	content[#content+1] = self:create "Label" {
		text = "No content 1",
		font = "default 16",
		textColor = self.palette.text,
	}

	return content
end

function SummaryDock:generateSubplans()
	local content = {}

	content[#content+1] = self:create "Label" {
		text = "No content 2",
		font = "default 16",
		textColor = self.palette.text
	}

	return content
end

function SummaryDock:generateStats()
	local content = {}

	content[#content+1] = self:create "Label" {
		text = "No content 3",
		font = "default 16",
		textColor = self.palette.text
	}

	return content
end

function SummaryDock:generateInsights()
	local content = {}

	content[#content+1] = self:create "Label" {
		text = "No content 4",
		font = "default 16",
		textColor = self.palette.text
	}

	return content
end

function SummaryDock:registerDiagramObject(diagram)
	self.diagram = diagram
end

function SummaryDock:hide()
	local ret = self.CompositeObject.hide(self)

	if not self.plan then
		return ret
	end

	self.diagram:moveRoot(self.w, 0)

	return ret
end

function SummaryDock:show()
	local ret = self.CompositeObject.show(self)

	if not self.plan then
		return ret
	end

	self.diagram:moveRoot(-self.w, 0)

	return ret
end

function SummaryDock:new()
	self.fill_flag = false

	self.currentContent = 0
	self.folds = self:createChild "SummaryFoldController" {}
	self.contentsContainer = self:createChild "Container" { w = "fill", h = "fill", padding = 15, gap = 10, horizontal = "left", vertical = "top", shear = true, scroll = true, hover = true, color = self.palette.main }

	self.folds:populate(folds)

	self:hide()
end

return SummaryDock