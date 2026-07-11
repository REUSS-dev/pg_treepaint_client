-- node

local GLOW_INTENSITY = 0.2
local GLOW_RANGE = COLORS.NODE_GLOW and 3 or 0

local HATCH_INTERVAL = 4

local NAVIGATION_OFFSET = 8

---@class DiagramNode : CompositeObject
---@field CompositeObject CompositeObject
---@field parent DiagramArea|DiagramHorizontalContainer|DiagramVerticalContainer
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field font love.Font
---@field select (DiagramHorizontalContainer|DiagramVerticalContainer)[]|false
---@field desc_font love.Font
---@field text_color ColorTable
---@field text_color_desc ColorTable
---@field hoverColor ColorTable
---@field node DumpedNode
---@field nodeType NodeType
---@field navigation {parent: DiagramNodeNavigation?, left: DiagramNodeNavigation[], right: DiagramNodeNavigation[], [integer]: DiagramNodeNavigation}
local DiagramNode = {
	name = "DiagramNode",
	extends = "CompositeObject",
	rules = {
		{{1, "node"}, "node"},
		{{"font"}, "font"},
		{{"desc_font", "font_s"}, "desc_font"},
		{{"hoverColor"}, "hoverColor"},
	},
	default = {
		w = 280, h = "hug",
		padding = {15, 10},
		gap = 5,
		horizontal = "left",

		colors = {
			main = COLORS.NODE_FILL,
			border = COLORS.NODE_BORDER,
			text = COLORS.NODE_TEXT
		},
		hoverColor = COLORS.NODE_HOVER,

		borderSize = 2,
		r = 10,
		hover = true
	},

	defaultCursor = "hand"
}

function DiagramNode:checkHover(x, y)
	local hover_object = self.CompositeObject.checkHover(self, x, y)

	if hover_object then
		return hover_object
	end

	if not self.select then
		return
	end

	for _, uiobject in ipairs(self.navigation) do
        local hl = uiobject:isInteractible() and uiobject:checkHover(x, y)

		if hl then
			return hl
		end
    end
end

function DiagramNode:paint()
	-- border
	for i = GLOW_RANGE, 1, -1 do
		love.graphics.setLineWidth(self.bsize + i*3)
		love.graphics.setColor(self.palette.border[1], self.palette.border[2], self.palette.border[3], GLOW_INTENSITY * i/(GLOW_RANGE + 1))
		love.graphics.rectangle("line", 0, 0, self.w, self.h, self.r)
	end

	if self.hl then
		love.graphics.setColor(self.hoverColor)
	else
		love.graphics.setColor(self.palette.main)
	end
	love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.r)

	love.graphics.setLineWidth(self.bsize)

	if self.select then
		local sm, sv = love.graphics.getStencilTest()
		love.graphics.stencil(self.stencil, "increment")
		love.graphics.setStencilTest("gequal", sv + 1)

		love.graphics.setColor(COLORS.NODE_SELECT)

		for x1 = self.r, self.w + self.h, self.bsize * HATCH_INTERVAL do
			love.graphics.line(x1, 0, 0, x1)
		end

		love.graphics.setStencilTest(sm, sv)
	end

	love.graphics.setColor(self.palette.border)
	love.graphics.rectangle("line", 0, 0, self.w, self.h, self.r)

	-- contents
	local tx, ty = self.titleContainer:getCoordinates()
    love.graphics.translate(tx, ty)
	self.titleContainer:paint()
	self.titleContainer:resetDirty()
    love.graphics.translate(-tx, -ty)

	if #self.contentsContainer.objects ~= 0 then
		tx, ty = self.contentsSeparator:getCoordinates()
		love.graphics.translate(tx, ty)
		self.contentsSeparator:paint()
		self.contentsSeparator:resetDirty()
		love.graphics.translate(-tx, -ty)
	end

	tx, ty = self.contentsContainer:getCoordinates()
    love.graphics.translate(tx, ty)
	self.contentsContainer:paint()
	self.contentsContainer:resetDirty()
    love.graphics.translate(-tx, -ty)

	tx, ty = self.footerContainer:getCoordinates()
    love.graphics.translate(tx, ty)
	self.footerContainer:paint()
	self.footerContainer:resetDirty()
    love.graphics.translate(-tx, -ty)

	if self.select then
		self:showNavigationObjects()

		for _, obj in ipairs(self:getNavigationObjects()) do
			if obj:isDrawn() then
				tx, ty = obj:getCoordinates()
				love.graphics.translate(tx, ty)
				obj:paint()
				obj:resetDirty()
				love.graphics.translate(-tx, -ty)
			end
		end
	end
end

function DiagramNode:click(_, _, but)
	if but == 1 then
		self.parent:renderNodeInfo(self)
	end
end

function DiagramNode:selectOn()
	self.select = self.parent:selectRelatives(self)
	self:showNavigationObjects()
	self:getObjectClass("DiagramContainer").setCurrentSelect(self)
end

function DiagramNode:selectOff()
	if not self.select then
		return
	end

	for _, relative in ipairs(self.select) do
		relative:resetSelect()
	end

	self.select = false

	self:hideNavigationObjects()

	self:getObjectClass("DiagramContainer").setCurrentSelect(nil)
end

--#region Navigation objects

function DiagramNode:getNavigationObjects()
	if not self.navigation then
		self:createNavigationObjects()
	end

	return self.navigation
end

function DiagramNode:createNavigationObjects()
	self.navigation = {
		left = {},
		right = {}
	}

	local parent = self:getParentNode()

	if parent then
		local parent_navigation = self:createChild "DiagramNodeNavigation" {
			compact = true,
			pointer = parent,
			style = "Up"
		}
		parent_navigation:hide()

		parent_navigation.x = self.w + NAVIGATION_OFFSET
		parent_navigation.y = -self.bsize * 2

		self.navigation.parent = parent_navigation
		self.navigation[#self.navigation+1] = parent_navigation
	end

	local children = self:getChildrenNodes()

	if #children == 0 then
		return
	end

	if #children == 1 then
		local child = children[1]

		local child_navigation = self:createChild "DiagramNodeNavigation" {
			compact = true,
			pointer = child,
			style = "Down"
		}
		child_navigation:hide()

		child_navigation.x = self.w + NAVIGATION_OFFSET
		child_navigation.y = self.h - child_navigation.h + self.bsize

		self.navigation.right[#self.navigation.right+1] = child_navigation
		self.navigation[#self.navigation+1] = child_navigation

		return
	end

	if #children % 2 == 0 then
		for i = 1, #children/2 do
			local child = children[i]

			local child_navigation = self:createChild "DiagramNodeNavigation" {
				pointer = child,
				style = "Left",
				ignore = true
			}
			child_navigation:hide()

			self.navigation.left[#self.navigation.left+1] = child_navigation
			self.navigation[#self.navigation+1] = child_navigation
		end

		for i = #self.navigation.left, 1, -1 do
			local obj = self.navigation.left[i]

			obj.x = -NAVIGATION_OFFSET - (self.navigation.left[i + 1] and self.navigation.left[i + 1].x or 0) - obj.w
			obj.y = self.h - obj.h + self.bsize
		end

		for i = #children/2 + 1, #children do
			local child = children[i]

			local child_navigation = self:createChild "DiagramNodeNavigation" {
				pointer = child,
				style = "Right",
				ignore = true
			}
			child_navigation:hide()

			self.navigation.right[#self.navigation.right+1] = child_navigation
			self.navigation[#self.navigation+1] = child_navigation
		end

		for i = 1, #self.navigation.right do
			local obj = self.navigation.right[i]

			obj.x = NAVIGATION_OFFSET + (self.navigation.right[i - 1] and (self.navigation.right[i - 1].x + self.navigation.right[i - 1].w + obj.w) or self.w)
			obj.y = self.h - obj.h + self.bsize
		end

		return
	end

	if #children % 2 == 1 then
		for i = 1, math.floor(#children/2) do
			local child = children[i]

			local child_navigation = self:createChild "DiagramNodeNavigation" {
				pointer = child,
				style = "Left",
				ignore = true
			}
			child_navigation:hide()

			self.navigation.left[#self.navigation.left+1] = child_navigation
			self.navigation[#self.navigation+1] = child_navigation
		end

		for i = #self.navigation.left, 1, -1 do
			local obj = self.navigation.left[i]

			obj.x = -NAVIGATION_OFFSET - (self.navigation.left[i + 1] and self.navigation.left[i + 1].x or 0) - obj.w
			obj.y = self.h - obj.h + self.bsize
		end

		do
			local child = children[math.ceil(#children/2)]

			local child_navigation = self:createChild "DiagramNodeNavigation" {
				pointer = child,
				style = "Down",
				ignore = true
			}
			child_navigation:hide()

			child_navigation.x = self.w + NAVIGATION_OFFSET
			child_navigation.y = self.h - child_navigation.h + self.bsize

			self.navigation.right[#self.navigation.right+1] = child_navigation
			self.navigation[#self.navigation+1] = child_navigation
		end

		for i = math.ceil(#children/2) + 1, #children do
			local child = children[i]

			local child_navigation = self:createChild "DiagramNodeNavigation" {
				pointer = child,
				style = "Right",
				ignore = true
			}
			child_navigation:hide()

			self.navigation.right[#self.navigation.right+1] = child_navigation
			self.navigation[#self.navigation+1] = child_navigation
		end

		for i = 1, #self.navigation.right do
			local obj = self.navigation.right[i]

			obj.x = NAVIGATION_OFFSET + (self.navigation.right[i - 1] and (self.navigation.right[i - 1].x + self.navigation.right[i - 1].w) or 0) + obj.w
			obj.y = self.h - obj.h + self.bsize
		end

		return
	end
end

function DiagramNode:showNavigationObjects()
	local navigation = self:getNavigationObjects()

	if #navigation.left > 0 then
		if self.parent:isCollapsed() then
			self:hideNavigationObjects()

			if navigation.parent then
				navigation.parent:show()
			end

			return
		end
	end

	if navigation.parent then
		navigation.parent:show()
	end

	for _, obj in ipairs(navigation.left) do
		obj:show()
	end

	for _, obj in ipairs(navigation.right) do
		obj:show()
	end
end

function DiagramNode:hideNavigationObjects()
	local navigation = self:getNavigationObjects()

	if navigation.parent then
		navigation.parent:hide()
	end

	for _, obj in ipairs(navigation.left) do
		obj:hide()
	end

	for _, obj in ipairs(navigation.right) do
		obj:hide()
	end
end

--#endregion

---@return DiagramNode?
function DiagramNode:getParentNode()
	if self.parent.name == "DiagramArea" then
		return nil
	end

	if self.parent.name == "DiagramHorizontalContainer" then
		if self.parent.parent.name == "DiagramVerticalContainer" then
			return self.parent.parent.master
		end

		return nil
	end

	if self.parent.name == "DiagramSubplanContainer" then
		return self.getParentNode(self.parent.parent)
	end

	if self.parent.name ~= "DiagramVerticalContainer" then
		return nil
	end

	if self.parent.objects[2] == self then
		return self.parent.master
	end

	if self.parent.parent.name == "DiagramSubplanContainer" then
		return self.getParentNode(self.parent.parent.parent)
	end

	if self.parent.parent.name == "DiagramVerticalContainer" then
		return self.parent.parent.master
	end

	if self.parent.parent.parent.name == "DiagramVerticalContainer" then
		return self.parent.parent.parent.master --[[@as DiagramNode]]
	end

	return nil
end

---@return DiagramNode[]
function DiagramNode:getChildrenNodes()
	if self.parent.name ~= "DiagramVerticalContainer" then
		return {}
	end

	if self.parent.master ~= self then
		return {}
	end

	if self.parent.slave.name == "DiagramHorizontalContainer" then
		return self:processChildren(self.parent.slave.objects)
	end

	if self.parent.slave.name == "DiagramVerticalContainer" then
		return self:processChildren({self.parent.slave.master --[[@as DiagramNode]]})
	end

	return self:processChildren({self.parent.slave})
end

function DiagramNode:processChildren(objects)
	local children = {}

	for i, child in ipairs(objects) do
		if child.name == "DiagramVerticalContainer" then
			children[i] = child.master
		elseif child.name == "DiagramSubplanContainer" then
			children[i] = child.node
		else
			children[i] = child
		end
	end

	return children
end

function DiagramNode:populateInfo(_)
	return {}
end

-- node fnc

function DiagramNode:new()
	assert(self.node, "DiagramNode object must be initialized with a DumpedNode object")

	self:setGrowth("vertical")

	self.select = false

	local node_data = self.node
	self.nodeType = self.node.type

	self.text_color = self.palette:getColorByIndex(2)

	if not self.palette:getColorByIndex(4) then
		self.palette:setColor(4, COLORS.NODE_TEXT_DESC)
	end
	self.text_color_desc = self.palette:getColorByIndex(4)

	self.stencil = function ()
		love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.r)
	end

	-- Children

	self.titleContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }
	self.titleContainer:createChild "Label" {
		font = self.font,
		horizontal = "left",
		text = node_data.type,
		textColor = self.text_color
	}

	self.contentsSeparator = self:createChild "Container" { color = {0.5, 0.5, 0.5, 1}, w = "fill", h = 1 }

	self.contentsContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	if node_data.timing then
		self.footerContainer:createChild "Label" {
			w = "fill",
			font = self.desc_font,
			horizontal = "right",
			textColor = self.text_color_desc,
			text = "Time: " .. node_data.timing.node.total[2] .. "ms",
		}
	elseif node_data.startup_cost then
		self.footerContainer:createChild "Label" {
			w = "fill",
			font = self.desc_font,
			horizontal = "right",
			textColor = self.text_color_desc,
			text = "Cost: " .. node_data.startup_cost .. ".." .. node_data.total_cost,
		}
	end
end

return DiagramNode