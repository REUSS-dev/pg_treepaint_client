-- MainPanel

---@class MainPanel : CompositeObject
---@field CompositeObject CompositeObject
---@field summary SummaryDock
---@field diagram DiagramArea
---@field info InfoPanel
local MainPanel = {
	name = "MainPanel",
	extends = "CompositeObject",
	default = {
		w = "fill",
		h = "fill",
		growth = "horizontal",
		gap = 0
	},
}

function MainPanel:registerDiagramObject(obj)
	obj:registerDiagramObject(self.diagram)
end

function MainPanel:new()
	self.summary = self:createChild "SummaryDock" {
		color = COLORS.SUMMARY_FILL
	}

	self.diagram = self:createChild "DiagramArea" {
		w = "fill",
		h = "fill",
		color = COLORS.BACKGROUND
	}

	self.info = self:createChild "InfoPanel" {
		color = COLORS.INFO_PANEL
	}

	self:registerDiagramObject(self.summary)
	self.diagram:registerSummary(self.summary)
	self.diagram:registerNodeInfo(self.info)
end

return MainPanel