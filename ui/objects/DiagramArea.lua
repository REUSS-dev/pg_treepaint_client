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

local GAP_HORIZONTAL = 25
local GAP_VERTICAL = 15

-- consts



-- vars

local pack_node, pack_node_list

-- init



-- fnc

---@param node DumpedNode
---@return CompositeObject
function pack_node(node)
	if not node.children then
		return gui.DiagramNode{node}
	end

	local vetical_container = gui.Container{ growth = "vertical", gap = GAP_VERTICAL }

	local node_object = gui.DiagramNode{node}
	vetical_container:add(node_object)

	local children_object = pack_node_list(node.children)
	vetical_container:add(children_object)

	return vetical_container
end

---@param node_list DumpedNode[]
---@return CompositeObject
function pack_node_list(node_list)
	if #node_list == 1 then
		return pack_node(node_list[1])
	end

	local horizontal_container = gui.Container{ growth = "horizontal", gap = GAP_HORIZONTAL }

	for _, node in ipairs(node_list) do
		local node_object = pack_node(node)
		horizontal_container:add(node_object)
	end

	return horizontal_container
end

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

	local root_node = pack_node(object_tree.root)

	self:add(root_node)

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