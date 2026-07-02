-- node

local GLOW_INTENSITY = 0.2
local GLOW_RANGE = 3

---@class DiagramNode : CompositeObject
---@field parent DiagramArea|DiagramHorizontalContainer|DiagramVerticalContainer
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field font love.Font
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

-- node fnc

function DiagramNode:new()
	assert(self.node, "DiagramNode object must be initialized with a DumpedNode object")

	self:setGrowth("vertical")

	local node_data = self.node
	self.nodeType = self.node.type

	self.text_color = self.palette:getColorByIndex(2)

	if not self.palette:getColorByIndex(4) then
		self.palette:setColor(4, COLORS.NODE_TEXT_DESC)
	end
	self.text_color_desc = self.palette:getColorByIndex(4)

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

	if node_data.startup_cost then
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