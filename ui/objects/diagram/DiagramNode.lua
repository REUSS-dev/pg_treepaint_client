-- node

local GLOW_INTENSITY = 0.2
local GLOW_RANGE = 3

local HATCH_INTERVAL = 4

---@class DiagramNode : CompositeObject
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
    love.graphics.translate(-tx, -ty)

	if #self.contentsContainer.objects ~= 0 then
		tx, ty = self.contentsSeparator:getCoordinates()
		love.graphics.translate(tx, ty)
		self.contentsSeparator:paint()
		love.graphics.translate(-tx, -ty)
	end

	tx, ty = self.contentsContainer:getCoordinates()
    love.graphics.translate(tx, ty)
	self.contentsContainer:paint()
    love.graphics.translate(-tx, -ty)

	tx, ty = self.footerContainer:getCoordinates()
    love.graphics.translate(tx, ty)
	self.footerContainer:paint()
    love.graphics.translate(-tx, -ty)
end

function DiagramNode:clickRelease(_, _, but)
	if but == 1 then
		self.parent:renderNodeInfo(self)
	end
end

function DiagramNode:selectOn()
	self.select = self.parent:selectRelatives(self)
end

function DiagramNode:selectOff()
	if not self.select then
		return
	end

	for _, relative in ipairs(self.select) do
		relative:resetSelect()
	end

	self.select = false
end

---@return DiagramNode?
function DiagramNode:getParentNode()
	if self.parent.name ~= "DiagramHorizontalContainer" and self.parent.name ~= "DiagramVerticalContainer" then
		return nil
	end

	if self.parent.name == "DiagramHorizontalContainer" then
		if self.parent.parent.name == "DiagramVerticalContainer" then
			return self.parent.parent.objects[1] --[[@as DiagramNode]]
		end

		return nil
	end

	if self.parent.name ~= "DiagramVerticalContainer" then
		return nil
	end

	if self.parent.objects[2] == self then
		return self.parent.objects[1] --[[@as DiagramNode]]
	end

	if self.parent.parent.name == "DiagramVerticalContainer" then
		return self.parent.parent.objects[1] --[[@as DiagramNode]]
	end

	if self.parent.parent.parent.name == "DiagramVerticalContainer" then
		return self.parent.parent.parent.objects[1] --[[@as DiagramNode]]
	end

	return nil
end

---@return DiagramNode[]
function DiagramNode:getChildrenNodes()
	if self.parent.name ~= "DiagramVerticalContainer" then
		return {}
	end

	if self.parent.objects[2].name == "DiagramHorizontalContainer" then
		return self.parent.objects[2].objects
	end

	if self.parent.objects[2].name == "DiagramVerticalContainer" then
		return {self.parent.objects[2].objects[1]}
	end

	return {self.parent.objects[2]}
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
			text = "Time: " .. node_data.timing.node.total[2] .. "s",
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