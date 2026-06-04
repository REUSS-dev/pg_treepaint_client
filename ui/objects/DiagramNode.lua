-- node
local node = {}

local gui = require("libs.stellargui")
local composite = require("classes.CompositeObject")

-- documentation



-- config

node.name = "DiagramNode"
node.aliases = {}
node.rules = {
    {"layout", {w = "hug", h = "hug", padding = 10}},
	{"palette", {additionalColor = {1, 1, 1, 1}, text_color = {1, 1, 1, 1}}},
	{{1, "node"}, "node", nil},

	{{"font"}, "font", love.graphics.getFont()},
	{{"bsize", "border_size", "borderSize"}, "bsize", 3}
}

-- consts



-- vars



-- init



-- fnc



-- classes

---@class DiagramNode : CompositeObject
---@field font love.Font
---@field node DumpedNode
---@field title Label
local DiagramNode = {}
local DiagramNode_meta = {__index = DiagramNode}
setmetatable(DiagramNode, {__index = composite.class}) -- Set parenthesis

-- node fnc

function node.new(prototype)
    local obj = composite.new(prototype)
    setmetatable(obj, DiagramNode_meta)
	---@cast obj DiagramNode

	assert(obj.node, "DiagramNode object must be initialized with a DumpedNode object")

	obj:setGrowth("vertical")

	local node_data = obj.node

	obj.title = gui.Label{
		font = obj.font,
		horizontal = "left",
		text = node_data.type
	}
	obj:add(obj.title)

    return obj
end

return node