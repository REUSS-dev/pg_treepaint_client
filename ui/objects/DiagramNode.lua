-- node

local GLOW_INTENSITY = 0.2
local GLOW_RANGE = 3

---@class DiagramNode : CompositeObject
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field font love.Font
---@field desc_font love.Font
---@field node DumpedNode
local DiagramNode = {
	name = "DiagramNode",
	extends = "CompositeObject",
	rules = {
		{{1, "node"}, "node"},
		{{"font"}, "font"},
		{{"desc_font", "font_s"}, "desc_font"}
	},
	default = {
		w = 250, h = "hug",
		padding = {15, 10},
		gap = 5,
		horizontal = "left",

		colors = {
			main = {32/255, 32/255, 32/255, 255/255},
			border = {1, 1, 1, 1},
			text = {1, 1, 1, 1}
		},
		borderSize = 2,
		r = 10
	}
}

function DiagramNode:paint()
	-- border
	for i = GLOW_RANGE, 1, -1 do
		love.graphics.setLineWidth(self.bsize + i*3)
		love.graphics.setColor(self.palette.border[1], self.palette.border[2], self.palette.border[3], GLOW_INTENSITY * i/(GLOW_RANGE + 1))
		love.graphics.rectangle("line", 0, 0, self.w, self.h, self.r)
	end

	love.graphics.setColor(self.palette.main)
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

-- node fnc

function DiagramNode:new()
	assert(self.node, "DiagramNode object must be initialized with a DumpedNode object")

	self:setGrowth("vertical")

	local node_data = self.node

	self.titleContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }
	self.titleContainer:createChild "Label" {
		font = self.font,
		horizontal = "left",
		text = node_data.type
	}

	self.contentsSeparator = self:createChild "Container" { color = {0.5, 0.5, 0.5, 1}, w = "fill", h = 1 }

	self.contentsContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }
	self.footerContainer:createChild "Label" {
		w = "fill",
		font = self.desc_font,
		horizontal = "right",
		textColor = {0.8, 0.8, 0.8, 1},
		text = "Cost: " .. node_data.startup_cost .. ".." .. node_data.total_cost,
	}
end

return DiagramNode