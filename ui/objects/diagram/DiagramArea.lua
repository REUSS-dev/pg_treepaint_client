-- diagram

local TreeParser = require("classes.TreeParser")

-- consts

local SPLASH_IMAGE = "assets/sad_malyar.png"

-- classes

---@class DiagramArea : CompositeObject
---@field CompositeObject CompositeObject
---@field nodeInfoObject InfoPanel
---@field minimap MinimapApplet
---@field summaryObject SummaryDock
---@field summaryToggle Button
---@field parser TreeParser
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
function DiagramArea:plot(data)
	local object_tree = self.parser:parse(data)

	if not object_tree then
		return
	end

	self.objects = {}
	self.cte_list = {}
	self.subplanContainers = {}
	self.subquery_counter = 0

	self.plan = object_tree
	self.root = self:packChild(object_tree.root)

	self:add(self.root)
	self.diagramFullSize = {self.root.w, self.root.h}
	self:createMinimap(self.root)

	self.root.layout.ignore = true
	self:collapseSubplans()
	self:moveRoot(0, 0)
	self.nodeInfoObject:hide()

	if self.summaryObject then
		self.summaryObject:applyPlan(object_tree)
		self:createSummaryToggle()
	end

	collectgarbage("collect")
end

---@param node_list DumpedNode[]
function DiagramArea:packNodeList(node_list)
	if #node_list == 1 then
		return self:packChild(node_list[1])
	end

	---@type DiagramHorizontalContainer
	local horizontal_container  = self:create "DiagramHorizontalContainer" { diagram = self }

	for _, node in ipairs(node_list) do
		local node_object = self:packChild(node)
		horizontal_container:add(node_object)
	end

	return horizontal_container
end

---@param node DumpedNode
---@protected
function DiagramArea:packChild(node)
	local packed = self:packNode(node)

	if node.relationship ~= "InitPlan" and node.relationship ~= "Subquery" and node.relationship ~= "SubPlan" then
		return packed
	end

	local subplan_container

	if node.relationship == "InitPlan" then
		subplan_container = self:create "DiagramSubplanContainer" { title = node.subplan, diagram = self }
			:pack(packed)

		if packed.name == "DiagramVerticalContainer" then
			self.cte_list[node.subplan] = packed.master
		else ---@cast packed DiagramNode
			self.cte_list[node.subplan] = packed
		end
	end

	if node.relationship == "Subquery" then
		self.subquery_counter = self.subquery_counter + 1

		local subquery_title = self:getObjectClass("Label").locale:format("plan.subquery", {self.subquery_counter})

		subplan_container = self:create "DiagramSubplanContainer" { title = subquery_title, diagram = self }
			:pack(packed)
	end

	if node.relationship == "SubPlan" then
		subplan_container = self:create "DiagramSubplanContainer" { title = node.subplan, diagram = self }
			:pack(packed)
	end

	self.subplanContainers[#self.subplanContainers+1] = subplan_container

	return subplan_container
end

---@param node DumpedNode
---@protected
function DiagramArea:packNode(node)
	if not node.children then
		return self:makeNodeObject(node)
	end

	---@type DiagramVerticalContainer
	local vetical_container = self:create "DiagramVerticalContainer" { diagram = self }

	local node_object = self:makeNodeObject(node)
	vetical_container:add(node_object)

	local children_object = self:packNodeList(node.children)

	if node_object.nodeType == "Gather" or node_object.nodeType == "Gather Merge" then
		---@cast children_object DiagramNode|DiagramVerticalContainer
		local worker_count = node_object.node.raw["Workers Launched"] or node_object.node.raw["Workers Planned"]

		local gather_title = worker_count and self:getObjectClass("Label").locale:format("plan.gather.additional_workers", {worker_count}) or "plan.gather.parallelized"

		local subplan_container = self:create "DiagramSubplanContainer" { title = gather_title, diagram = self, kind = "workers" }
			:pack(children_object)

		self.subplanContainers[#self.subplanContainers+1] = subplan_container

		vetical_container:add(subplan_container)
		return vetical_container
	end

	vetical_container:add(children_object)

	return vetical_container
end

---@param node DumpedNode
---@return DiagramNode
---@protected
function DiagramArea:makeNodeObject(node)
	local node_type_no_space = string.gsub(node.type, " ", "")

	local specific_node_descriptor = self:getObjectClass("DiagramNode" .. node_type_no_space) or self:getObjectClass("DiagramNode")

	return specific_node_descriptor {
		node,
		diagram = self
	}
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

	self:createSplash()
end

return DiagramArea