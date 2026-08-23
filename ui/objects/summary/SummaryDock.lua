-- SummaryDock

local conf_defaults = require("scripts.conf_default")

-- Folds contents

local folds = {
	{"triggerInfo", "summary.tabs.info"},
	{"triggerSubplans", "summary.tabs.subplans"},
	{"triggerStats", "summary.tabs.stats"},
	{"triggerInsights", "summary.tabs.insights"},
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
		padding = {0, 0, 0, 15},

		color = COLORS.SUMMARY_FILL,
		textColor = COLORS.COLOR_TEXT_1
	},
}

---@param new_plan DumpedPlan
function SummaryDock:applyPlan(new_plan)
	self.plan = new_plan

	self:generateContent()
	self.folds:triggerDefault()
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
	self.contentsContainer:relayout()
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
	self.contentsContainer:relayout()
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
	self.contentsContainer:relayout()
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
	self.contentsContainer:relayout()
end

--#endregion

function SummaryDock:generateContent()
	self.content = {}

	self.content[1] = self:generateInfo()
	self.content[2] = self:generateSubplans()
	self.content[3] = self:generateStats()
	self.content[4] = self:generateInsights()

	self.currentContent = 0
end

function SummaryDock:generateInfo()
	self.contentsContainer.objects = {}

	local plan = self.plan

	self.contentsContainer:createChild "SummaryInfoHead" {
		plan = plan
	}

	if plan.timing then
		local timings = self.contentsContainer:createChild "SectionContainer" {
			title = "summary.info.timing.title",
			collapsible = false
		}

		timings.contents.layout.gap = 5

		if plan.timing.execution then
			local exe = self:create "Label" {
				w = "fill",
				horizontal = "right",

				text = "summary.info.timing.execution",
				with = {plan.timing.execution},
				font = "default 18",
				textColor = COLORS.SUMMARY_TEXT,
			}
			timings:addObject(exe)
		end

		if plan.timing.planning then
			local planning = self:create "Label" {
				w = "fill",
				horizontal = "right",

				text = "summary.info.timing.planning",
				with = {plan.timing.planning},
				font = "default 18",
				textColor = COLORS.SUMMARY_TEXT,
			}
			timings:addObject(planning)
		end

		if plan.timing.execution and plan.timing.planning then
			local divider = self:create "Container" {
				w = "fill",
				padding = {75, 0, 0, 0}
			}
			divider:createChild "Container" {
				w = "fill",
				h = 1,
				color = COLORS.COLOR_SECONDARY_0
			}
			timings:addObject(divider)

			local total = timings:create "Label" {
				w = "fill",
				horizontal = "right",

				text = "summary.info.timing.total",
				with = {string.format("%.3f", (plan.timing.execution + plan.timing.planning))},
				font = "default 18",
				textColor = COLORS.SUMMARY_TEXT,
			}
			timings:addObject(total)
		end
	end

	if plan.buffers then
		local buffers = self.contentsContainer:createChild "SectionContainer" {
			title = "summary.info.buffers.title",
			gap = 5,
			collapsible = false,
			no_div = true,
		}

		local buffer_table = self:create "BufferSheet" {
			buffers = plan.buffers.total,
			group = "summary_total"
		}
		buffers:addObject(buffer_table)

		if plan.buffers.planning then
			buffers:addDivider({0, 5, 0, 2}, true)

			local planning = self:create "SectionContainer" { title = "summary.info.buffers.title_planning", borderless = true, no_div = true }

			planning:addObject(self:create "BufferSheet" {
				buffers = plan.buffers.planning,
				group = "summary_planning"
			})

			planning:addObject(self:create "Label" {
				text = "summary.info.buffers.planning_tip",
				w = "fill",
				horizontal = "center",
				font = "default 16",
				textColor = COLORS.NODE_TEXT_GREYED
			})

			buffers:add(planning)
		end
	end

	local root = plan.root

	if root.raw["Actual Rows"] or root.raw["Output"] then
		local output = self.contentsContainer:createChild "SectionContainer" {
			title = "summary.info.output.title",
			group = "summary_output"
		}

		output:addTextParametrized("summary.info.output.rows", root.raw["Actual Rows"])

		if root.raw["Output"] then
			if root.raw["Actual Rows"] then
				output:addText("")
			end

			output:addTextParametrized("summary.info.output.columns", #root.raw["Output"])
			local divider = self:create "Container" {
				w = "fill",
				h = 1,
				color = COLORS.COLOR_SECONDARY_0
			}
			output:addObject(divider)

			output:addText(table.concat(root.raw["Output"], ";\n"))
		end
	end

	if plan.wal then
		local wal = self.contentsContainer:createChild "SectionContainer" {
			title = "summary.info.wal.title",
			group = "summary_wal"
		}

		local wal_main = self.plan.wal

		if wal_main.records == 0 then
			wal:addText("info.wal.no_wal")
		else
			if wal_main.bytes and wal_main.bytes > 0 then
				wal:addTextParametrized("info.wal.records_bytes", {wal_main.records, wal_main.bytes})
			else
				wal:addTextParametrized("info.wal.records", wal_main.records)
			end

			if wal_main.fpi_bytes and wal_main.fpi_bytes > 0 then
				wal:addTextParametrized("info.wal.fpi_bytes", {wal_main.fpi, wal_main.fpi_bytes})
			else
				wal:addTextParametrized("info.wal.fpi", wal_main.fpi)
			end

			wal:addTextParametrized("info.wal.buffers_full", wal_main.buffers_full)
		end
	end

	if plan.identifier then
		local id = self.contentsContainer:createChild "SectionContainer" {
			title = "summary.info.identifier.title"
		}

		id:addText(plan.identifier)
	end

	if plan.settings then
		local label_sets = {}

		for setting, value in pairs(plan.settings) do
			label_sets[#label_sets+1] = {setting .. " = " .. value, conf_defaults.get(setting)}
		end

		if #label_sets > 0 then
			local section = self.contentsContainer:createChild "SectionContainer" {
				title = "summary.info.settings.title",
				no_div = true,
			}

			local header_container = self:create "Container" { w = "fill", growth = "horizontal", gap = 5 }
			header_container:createChild "Label" {
				w = "fill",
				horizontal = "left",

				text = "summary.info.settings.parameter",
				font = "default 18",
				textColor = self.palette.text
			}
			header_container:createChild "Label" {
				w = "hug",
				horizontal = "right",

				text = "summary.info.settings.default",
				font = "default 18",
				textColor = COLORS.COLOR_TEXT_2
			}
			section:addObject(header_container)

			section:addDivider({0, 2}, true)

			for _, labelset in ipairs(label_sets) do
				local setting_container = self:create "Container" { w = "fill", growth = "horizontal", gap = 5 }
				setting_container:createChild "Label" {
					w = "fill",
					horizontal = "left",

					text = labelset[1],
					font = "default 17",
					textColor = self.palette.text
				}
				setting_container:createChild "Label" {
					w = "hug",
					horizontal = "right",

					text = labelset[2],
					font = "default 17",
					textColor = COLORS.COLOR_TEXT_2
				}
				section:addObject(setting_container)
			end
		end
	end

	return self.contentsContainer.objects
end

function SummaryDock:generateSubplans()
	self.contentsContainer.objects = {}

	self.contentsContainer:createChild "Label" {
		text = "No content 2",
		font = "default 16",
		textColor = self.palette.text
	}

	return self.contentsContainer.objects
end

function SummaryDock:generateStats()
	self.contentsContainer.objects = {}

	self.contentsContainer:createChild "Label" {
		text = "No content 3",
		font = "default 16",
		textColor = self.palette.text
	}

	return self.contentsContainer.objects
end

function SummaryDock:generateInsights()
	self.contentsContainer.objects = {}

	self.contentsContainer:createChild "Label" {
		text = "No content 4",
		font = "default 16",
		textColor = self.palette.text
	}

	return self.contentsContainer.objects
end

---@param diagram DiagramArea
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
	self.currentContent = 0
	self.folds = self:createChild "SummaryFoldController" {}
	self.contentsContainer = self:createChild "Container" { w = "fill", h = "fill", padding = 15, gap = 10, horizontal = "left", vertical = "top", shear = true, scroll = true, hover = true }

	self.folds:populate(folds)

	self:hide()
end

return SummaryDock