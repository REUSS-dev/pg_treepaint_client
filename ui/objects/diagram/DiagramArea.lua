-- diagram

local TreeParser = require("classes.TreeParser")

-- classes

---@class DiagramArea : CompositeObject
---@field CompositeObject CompositeObject
---@field nodeInfoObject InfoPanel
---@field font love.Font
---@field parser TreeParser
---@field root CompositeObject?
---@field mouse_held {[1]: integer, [2]: integer}?
---@field mouse_held_origin {[1]: integer, [2]: integer}?
local DiagramArea = {
	name = "DiagramArea",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"},
	},
	default = {
		w = "fill", h = "fill",
		text_color = {1, 1, 1, 1},
		font = love.graphics.getFont(),
		vertical = "top",
		padding = {0, 50, 0, 0},
		hoverSelf = true,
		shear = true
	},
}

-- consts

local MOVE_MAX = 200

-- diagram fnc

function DiagramArea:click(x, y, but)
	if but == 1 then
		self.mouse_held = {x, y}
		self.mouse_held_origin = {x, y}
	end
end

function DiagramArea:clickRelease(x, y, but)
	if but == 1 then
		if x == self.mouse_held_origin[1] and y == self.mouse_held_origin[2] then
			self.nodeInfoObject:hide()
		end

		self.mouse_held = nil
		self.mouse_held_origin = nil
	end
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

function DiagramArea:resize(new_w, new_h, relayout)
	self.CompositeObject.resize(self, new_w, new_h, relayout)

	self:moveRoot(0, 0)
end

function DiagramArea:wheel(x, y)
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

	self.root = self:packChild(object_tree.root)

	self:add(self.root)

	self.root.layout.ignore = true
	self:moveRoot(0, 0)
	self.nodeInfoObject:hide()

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

	if node.relationship == "InitPlan" then
		---@type DiagramSubplanContainer
		local subplan_container = self:create "DiagramSubplanContainer" { title = node.subplan, font = self.font, diagram = self }
			:pack(packed)

		return subplan_container
	end

	return packed
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

---@param node_info_object InfoPanel
function DiagramArea:registerNodeInfo(node_info_object)
	self.nodeInfoObject = node_info_object
end

function DiagramArea:selectRelatives(_)
	return {}
end

function DiagramArea:resetSelect(_)
	return {}
end

function DiagramArea:new()
	self:setGrowth("horizontal")

	self.parser = TreeParser()
end

return DiagramArea