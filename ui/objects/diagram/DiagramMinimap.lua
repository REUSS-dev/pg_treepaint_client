-- DiagramMinimap.lua

-- consts

local DEFAULT_DIMENSIONS = {200, 200}

---@class DiagramMinimap : ObjectUI
---@field scale number
---@field root DiagramNode|DiagramContainer
---@field diagram DiagramArea
---@field mapCanvas love.Canvas
---@field globalOffset {[1]: integer, [2]: integer}
---@field palette Palette
---@field dirty boolean
local DiagramMinimap = {
	name = "DiagramMinimap",
	extends = "ObjectUI",
	rules = {
		{{"scale"}, "scale"},
		{{1, "node", "root"}, "root"},
		"palette"
	},
	default = {
		w = MINIMAP_DIMENSIONS and MINIMAP_DIMENSIONS[1] or DEFAULT_DIMENSIONS[1],
		h = MINIMAP_DIMENSIONS and MINIMAP_DIMENSIONS[2] or DEFAULT_DIMENSIONS[2],
		padding = 15,

		color = {1, 1, 1, 0.75},
		additionalColor = COLORS.MINIMAP_PACKGROUND,

		scale = 0.075
	},

	bsize = 2
}

function DiagramMinimap:checkHover()
	return false
end

function DiagramMinimap:paint()
	love.graphics.setColor(self.palette.main)

	local map = self:getMinimap()

	local ww, wh = math.floor(self.diagram.w * self.scale + .5), math.floor(self.diagram.h * self.scale + .5)
	local wx, wy = math.floor((-self.diagram.root.x) * self.scale + .5) + self.centeringOffset[1], math.floor((-self.diagram.root.y) * self.scale + .5) + self.centeringOffset[2]

	local x_offset, y_offset = math.floor((self.w - ww)/2 + .5) - wx, math.floor((self.h - wh)/2 + .5) - wy
	x_offset, y_offset = math.min(0, math.max(self.w - math.floor(self.root.w * self.scale + .5), x_offset)), math.min(0, math.max(self.h - math.floor(self.root.h * self.scale + .5), y_offset))

	love.graphics.translate(x_offset, y_offset)

	local sx, sy, sw, sh = love.graphics.getScissor()
	local tx, ty = self:getTranslation(true)
	love.graphics.intersectScissor(tx, ty, self.w, self.h)

	love.graphics.draw(map)

	love.graphics.setScissor(sx, sy, sw, sh)

	if not self.diagram then
		return
	end

	if wx < 0 then
		ww = ww + wx
		wx = 0
	end

	if wy < 0 then
		wh = wh + wy
		wy = 0
	end

	ww = (wx + x_offset) + ww > self.w and ww - ((wx + x_offset) + ww - self.w) or ww
	wh = (wy + y_offset) + wh > self.h and wh - ((wy + y_offset) + wh - self.h) or wh

	love.graphics.setColor(COLORS.CONNECTION_HOVER)
	love.graphics.setLineWidth(self.bsize * 2)
	love.graphics.rectangle("line", wx, wy, ww, wh)

	love.graphics.translate(-x_offset, -y_offset)
end

function DiagramMinimap:createCanvas()
	self.diagram = self.root.parent --[[@as DiagramArea]]

	if self.mapCanvas then self.mapCanvas:release() end

	local canvas_w, canvas_h = self:calculateCanvasResolution()

	if not canvas_w or not canvas_h then
		print("System canvas size limit hit")
		return
	end

	self.mapCanvas = love.graphics.newCanvas(canvas_w, canvas_h)
	self.globalOffset = {}
	self.centeringOffset = {}

	self.dirty = true
end

---@param scale number?
---@return integer?
---@return integer?
function DiagramMinimap:calculateCanvasResolution(scale)
	scale = scale or self.scale

	local w, h = self.diagram.diagramFullSize[1], self.diagram.diagramFullSize[2]

	local canvas_w, canvas_h = math.max(self.layout.w --[[@as number]], math.ceil(w * scale)), math.max(self.layout.h --[[@as number]], math.ceil(h * scale))

	local limits = love.graphics.getSystemLimits()

	if canvas_w > limits.texturesize or canvas_h > limits.texturesize then
		return nil
	end

	return canvas_w, canvas_h
end

---@public
function DiagramMinimap:refreshMinimap()
	self.dirty = true
end

---@private
function DiagramMinimap:getMinimap()
	if self.dirty then
		self:renderMinimap()
	end

	return self.mapCanvas
end

function DiagramMinimap:getScale()
	return self.scale
end

---@param new_scale number
---@return DiagramMinimap? self
function DiagramMinimap:setScale(new_scale)
	if not self:calculateCanvasResolution(new_scale) then
		return nil
	end

	self.scale = new_scale

	self:createCanvas()
	self:redraw()

	return self
end

--#region Minimap render

---@private
function DiagramMinimap:renderMinimap()
	love.graphics.push("all")
	love.graphics.origin()
	love.graphics.setScissor()
	love.graphics.setCanvas(self.mapCanvas)

	love.graphics.setColor(self.palette.border)
	love.graphics.setLineWidth(self.bsize)
	love.graphics.rectangle("fill", 0, 0, self.mapCanvas:getDimensions())

	local root_tx, root_ty = self.root:getTranslation()
	local cx, cy = math.max(0, (self.layout.w - self.root.w * self.scale)/2), math.max(0, (self.layout.h - self.root.h * self.scale)/2)
	self.centeringOffset = {cx, cy}

	self.globalOffset[1] = -root_tx * self.scale + cx
	self.globalOffset[2] = -root_ty * self.scale + cy

	self:renderElement(self.root)

	love.graphics.pop()

	self.dirty = false
end

---@private
---@param object DiagramContainer|DiagramNode
function DiagramMinimap:renderElement(object)
	if object.name == "DiagramVerticalContainer" then ---@cast object DiagramVerticalContainer
		self:renderVerticalContainer(object)
	elseif object.name == "DiagramHorizontalContainer" then ---@cast object DiagramHorizontalContainer
		self:renderHorizontalContainer(object)
	elseif object.name == "DiagramSubplanContainer" then ---@cast object DiagramSubplanContainer
		self:renderSubplanContainer(object)
	else ---@cast object DiagramNode
		self:renderNode(object)
	end
end

---@private
---@param object DiagramVerticalContainer
function DiagramMinimap:renderVerticalContainer(object)
	self:renderElement(object.master)

	if object:isCollapsed() then
		return
	end

	love.graphics.setColor(COLORS.CONNECTION)

	local tx, ty = object.master:getTranslation()
	tx, ty = tx * self.scale + self.globalOffset[1], math.floor(ty * self.scale + self.globalOffset[2] + .5)
	local w, h = object.master.w * self.scale, math.floor(object.master.h * self.scale + .5)

	local conn_x1 = tx + w/2
	local conn_y1 = ty + h
	local conn_x2 = conn_x1
	local conn_y2 = math.max(conn_y1 + 1, conn_y1 + object.layout.gap/2 * self.scale)

	love.graphics.line(conn_x1, conn_y1, conn_x2, conn_y2)

	self:renderElement(object.slave)
end

---@private
---@param object DiagramHorizontalContainer
function DiagramMinimap:renderHorizontalContainer(object)
	for _, element in ipairs(object.objects) do
		self:renderElement(element)
	end

	local tx1, ty1 = object.objects[1]:getTranslation()
	tx1, ty1 = math.floor(tx1 * self.scale + self.globalOffset[1] + .5), math.floor(ty1 * self.scale + self.globalOffset[2] + .5)
	local w1 = math.floor(object.objects[1].w * self.scale + .5)

	local tx2 = object.objects[#object.objects]:getTranslation()
	tx2 = math.floor(tx2 * self.scale + self.globalOffset[1] + .5)
	local w2 = math.floor(object.objects[#object.objects].w * self.scale + .5)

	love.graphics.setColor(COLORS.CONNECTION)

	local conn_x1 = math.floor(tx1 + w1/2 + .5)
	local conn_y1 = ty1 - object.parent.layout.gap/2 * self.scale
	local conn_x2 = math.floor(tx2 + w2/2 + .5)
	local conn_y2 = conn_y1

	love.graphics.line(conn_x1, conn_y1, conn_x2, conn_y2)
end

---@private
---@param object DiagramSubplanContainer
function DiagramMinimap:renderSubplanContainer(object)
	love.graphics.setColor((COLORS.CONNECTION[1] + 0.5)/2, (COLORS.CONNECTION[2] + 0.5)/2, (COLORS.CONNECTION[3] + 0.5)/2, COLORS.CONNECTION[4])

	local tx, ty = object:getTranslation()
	tx, ty = tx * self.scale + self.globalOffset[1], math.floor(ty * self.scale + self.globalOffset[2] + .5) + 1
	local w, h = object.w * self.scale, object.h * self.scale

	love.graphics.rectangle("line", math.floor(tx + .5), ty, math.floor(w + .5), math.floor(h + .5))

	if object:isCollapsed() then
		love.graphics.setColor(COLORS.CONNECTION)

		local conn_x1 = tx + w/2
		local conn_y1 = ty - 1
		local conn_x2 = conn_x1
		local conn_y2 = conn_y1 - object.parent.layout.gap/2 * self.scale

		love.graphics.line(conn_x1, conn_y1, conn_x2, conn_y2)

		return
	end

	love.graphics.setColor(COLORS.CONNECTION)

	tx = object:getTranslation()
	tx = tx * self.scale + self.globalOffset[1]

	local conn_x1 = tx + w/2
	local conn_y1 = ty - object.parent.layout.gap/2 * self.scale
	local conn_x2 = conn_x1
	local conn_y2 = ty + object.parent.layout.gap*2 * self.scale

	love.graphics.line(conn_x1, conn_y1, conn_x2, conn_y2)

	self:renderElement(object.subplanContainer.objects[1] --[[@as DiagramVerticalContainer|DiagramNode]])
end

---@private
---@param object DiagramNode
function DiagramMinimap:renderNode(object)
	love.graphics.setColor(object.palette.border)

	local tx, ty = object:getTranslation()
	tx, ty = math.floor(tx * self.scale + self.globalOffset[1] + .5), math.floor(ty * self.scale + self.globalOffset[2] + .5)
	local w, h = math.floor(object.w * self.scale + .5), math.floor(object.h * self.scale + .5)

	love.graphics.rectangle("fill", tx, ty, w, h, 3)

	if object.select then
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.rectangle("line", tx, ty, w, h, 3)
	end

	if object.parent.name == "DiagramArea" or object.parent.parent.name == "DiagramArea" then
		return
	end

	love.graphics.setColor(COLORS.CONNECTION)

	local conn_x1 = tx + object.w/2 * self.scale
	local conn_y1 = ty
	local conn_x2 = conn_x1
	local conn_y2 = ty - object.parent.layout.gap/2 * self.scale

	love.graphics.line(conn_x1, conn_y1, conn_x2, conn_y2)
end

--#endregion

function DiagramMinimap:new()
	assert(type(self.root) == "table", "DiagramMinimap: Diagram root object is required to create diagram minimap")

	self:createCanvas()
end

return DiagramMinimap