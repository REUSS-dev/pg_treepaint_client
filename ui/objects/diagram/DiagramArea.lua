-- diagram

local TreeParser = require("classes.TreeParser")
local PlanConstructor = require("classes.PlanConstructor")
local QueryConstructor = require("classes.QueryConstructor")

-- consts

---@enum PlotTarget
local PlotTarget = {
	PLAN = "plan",
	QUERY = "query",
	REWRITTEN = "rewritten"
}

local SPLASH_IMAGE = "assets/sad_malyar.png"

-- classes

---@class DiagramArea : CompositeObject
---@field CompositeObject CompositeObject
---@field nodeInfoObject InfoPanel
---@field minimap MinimapApplet
---@field summaryObject SummaryDock
---@field summaryToggle Button
---@field parser TreeParser
---@field planConstructor PlanConstructor
---@field queryConstructor QueryConstructor
---@field plan DumpedPlan
---@field root DiagramNode|DiagramContainer?
---@field mouse_held {[1]: integer, [2]: integer}?
---@field mouse_held_origin {[1]: integer, [2]: integer}?
---@field cte_list table<string, DiagramNode>
---@field subquery_counter integer
---@field subplanContainers DiagramSubplanContainer[]
---@field diagramFullSize integer[]
local DiagramArea = {
	name = "DiagramArea",
	extends = "CompositeObject",
	rules = {},
	default = {
		w = "fill", h = "fill",
		text_color = {1, 1, 1, 1},
		vertical = "top",
		padding = {0, 50, 0, 0},
		hoverSelf = true,
		shear = true
	},
}

-- consts

local MINIMAP_MARGIN = 15
local MOVE_MAX = 200

-- diagram fnc

--#region UI Object overrides

function DiagramArea:click_left(x, y)
	self.mouse_held = {x, y}
	self.mouse_held_origin = {x, y}
end

function DiagramArea:clickRelease_left(x, y)
	if x == self.mouse_held_origin[1] and y == self.mouse_held_origin[2] then
		self.nodeInfoObject:hide()
	end

	self.mouse_held = nil
	self.mouse_held_origin = nil
end

function DiagramArea:tick(dt)
	self.CompositeObject.tick(self, dt)

	if self.root and self.mouse_held then
		local mx, my = self:convertGlobalCoords(love.mouse.getPosition())

		if mx ~= self.mouse_held[1] or my ~= self.mouse_held[2] then
			self:moveRoot(mx - self.mouse_held[1], my - self.mouse_held[2])

			self.mouse_held[1] = mx
			self.mouse_held[2] = my
		end
	end
end

function DiagramArea:autolayout(...)
	self.CompositeObject.autolayout(self, ...)

	if not self.minimap then
		return
	end

	self.minimap.x = self.w - self.minimap.w - MINIMAP_MARGIN
	self.minimap.y = MINIMAP_MARGIN

	self.minimap:refreshMinimap()
end

function DiagramArea:resize(new_w, new_h, relayout)
	self.CompositeObject.resize(self, new_w, new_h, relayout)

	self:moveRoot(0, 0)
end

function DiagramArea:wheel(x, y)
	if x == 0 and y == 0 then
		return
	end

	if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and x == 0 then
		self:moveRoot(y * 20, 0)
		return
	end

	self:moveRoot(x * -20, y * 20)
end

--#endregion

---@param x pixels
---@param y pixels
function DiagramArea:moveRoot(x, y)
	if not self.root then
		return
	end

	x, y = math.floor(x + .5), math.floor(y + .5)

	local new_x, new_y

	if self.root.w + 2*MOVE_MAX> self.w then
		new_x = math.max(self.w - self.root.w - MOVE_MAX, math.min(MOVE_MAX, self.root.x + x))
	else
		new_x = math.floor((self.w - self.root.w)/2 + .5)
	end

	if self.root.h + 2*MOVE_MAX > self.h then
		new_y = math.max(self.h - self.root.h - MOVE_MAX, math.min(MOVE_MAX, self.root.y + y))
	else
		new_y = math.floor((self.h - self.root.h)/2 + .5)
	end

	if new_x == self.root.x and new_y == self.root.y then
		return
	end

	self.root:move(new_x, new_y)
	self:redraw()
end

---@param node DiagramNode
---@param refocus boolean?
function DiagramArea:renderNodeInfo(node, refocus)
	if self.nodeInfoObject then
		self.nodeInfoObject:displayNode(node)

		if not refocus then
			return
		end

		local parent = node.parent

		while parent.name ~= "DiagramArea" do ---@cast parent DiagramContainer
			if parent:isCollapsed() then
				---@cast parent DiagramVerticalContainer|DiagramSubplanContainer
				parent:toggleCollapse()
			end

			parent = parent.parent
		end
	end
end

---@param data string
---@param target PlotTarget?
function DiagramArea:plot(data, target)
	local object_tree = self.parser:parse(data)

	if not object_tree then
		return
	end

	self.plan = object_tree

	target = target or PlotTarget.PLAN

	self.objects = {}

	if target == PlotTarget.PLAN then
		self:plotPlan(target)
	elseif target == PlotTarget.QUERY or target == PlotTarget.REWRITTEN then
		self:plotQuery(target)
	end

	if not self.root then
		return
	end

	self:add(self.root)
	self.diagramFullSize = {self.root.w, self.root.h}
	self:createMinimap(self.root)

	self.root.layout.ignore = true
	self:collapseSubplans()
	self:moveRoot(0, 0)
	self.nodeInfoObject:hide()

	if self.summaryObject then
		self.summaryObject:applyPlan(object_tree, target)
		self:createSummaryToggle()
	end

	collectgarbage("collect")
end

---@param target PlotTarget
function DiagramArea:plotPlan(target)
	self.cte_list = {}
	self.subplanContainers = {}
	self.subquery_counter = 0

	self.root = self.planConstructor:generate(self.plan.root)
end

---@param target PlotTarget
function DiagramArea:plotQuery(target)
	if not self.plan.query then
		return
	end

	if target == PlotTarget.QUERY then
		if not self.plan.query.original then
			return
		end

		self.root = self.queryConstructor:generate(self.plan.query.original)
	elseif target == PlotTarget.REWRITTEN then
		if not self.plan.query.rewritten then
			return
		end

		self.root = self.queryConstructor:generate(self.plan.query.rewritten)
	end
end

---@param node DiagramNode|DiagramContainer
function DiagramArea:createMinimap(node)
	self.minimap = self:createChild "MinimapApplet" {node}

	self.minimap.x = self.w - self.minimap.w - MINIMAP_MARGIN
	self.minimap.y = MINIMAP_MARGIN
end

function DiagramArea:refreshMinimap()
	self.minimap:refreshMinimap()
end

function DiagramArea:collapseSubplans()
	for _, subplan in ipairs(self.subplanContainers) do
		subplan:maybeCollapse()
	end
end

function DiagramArea:createSummaryToggle()
	if not self.summaryObject then
		return
	end

	self.summaryToggle = self:createChild "SummaryToggle" {
		summary = self.summaryObject
	}
	self.summaryToggle.x = 0
	self.summaryToggle.y = 50
end

---@param summary_object SummaryDock
function DiagramArea:registerSummary(summary_object)
	self.summaryObject = summary_object
end

---@param node_info_object InfoPanel
function DiagramArea:registerNodeInfo(node_info_object)
	self.nodeInfoObject = node_info_object
end

function DiagramArea:createSplash()
	local container = self:createChild "Container" {
		growth = "vertical",
		padding = {0, 0, 0, 50},
		w = "hug",
		h = "fill",
		gap = 15
	}

	container:createChild "Image" {
		image = SPLASH_IMAGE,
		display = "fixed",
		limit = 0.75,
		w = "hug",
		h = "hug"
	}

	container:createChild "Label" {
		font = "default 52",
		text = "plan.noplan.header",
		textColor = COLORS.COLOR_TEXT_1
	}

	container:createChild "Label" {
		font = "default 20",
		text = "plan.noplan.hint",
		horizontal = "center",
		w = "fill",
		textColor = COLORS.COLOR_TEXT_1
	}

	container:createChild "Label" {
		font = "default 18",
		text = "plan.noplan.hint_extension",
		horizontal = "center",
		w = "fill",
		textColor = COLORS.COLOR_TEXT_1
	}

	container:createChild "Button" {
		text = "plan.noplan.extension_button_text",
		font = "default 18",
		w = "hug",
		h = "hug",
		color = COLORS.BUFFER_BUTTON_FILL,
		additionalColor = COLORS.BUFFER_BUTTON_BORDER,
		action = function ()
			love.system.openURL(IDENTITY.extension_url)
		end
	}
end

function DiagramArea:selectRelatives(_)
	return {}
end

function DiagramArea:resetSelect(_)
	return {}
end

function DiagramArea:new()
	self:setGrowth("horizontal")

	self.cte_list = {}
	self.subquery_counter = 0
	self.subplanContainers = {}

	self.parser = TreeParser()
	self.planConstructor = PlanConstructor(self)
	self.queryConstructor = QueryConstructor(self)

	self:createSplash()
end

return DiagramArea