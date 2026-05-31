-- diagram
local diagram = {}

local gui = require("libs.stellargui")
local composite = require("classes.CompositeObject")

local TreeParser = require("classes.TreeParser")

-- documentation



-- config

diagram.name = "DiagramArea"
diagram.aliases = {}
diagram.rules = {
    {"layout", {w = "fill", h = "fill"}},
	{"palette", {text_color = {1, 1, 1, 1}}},

	{{"font"}, "font", love.graphics.getFont()},
}

-- consts



-- vars



-- init



-- fnc



-- classes

---@class DiagramArea : CompositeObject
---@field font love.Font
---@field parser TreeParser
local DiagramArea = {}
local DiagramArea_meta = {__index = DiagramArea}
setmetatable(DiagramArea, {__index = composite.class}) -- Set parenthesis

-- diagram fnc

function DiagramArea:plot(data)
	local object_tree = self.parser:parse(data)

	self.objects = {}

	local babalabel = gui.Label{
		text = "Loaded tree with " .. #object_tree .. " items",
		font = self.font
	}
	self:add(babalabel)

	collectgarbage("collect")
end

function diagram.new(prototype)
    local obj = composite.new(prototype)
    setmetatable(obj, DiagramArea_meta)
	---@cast obj DiagramArea
	
	obj:setGrowth("horizontal")

	obj.parser = TreeParser()

    return obj
end

return diagram