-- diagram

local TreeParser = require("classes.TreeParser")

-- classes

---@class DiagramArea : CompositeObject
---@field CompositeObject CompositeObject
---@field font love.Font
---@field parser TreeParser
local DiagramArea = {
	name = "DiagramArea",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"},
	},
	default = {
		w = "fill", h = "fill",
		text_color = {1, 1, 1, 1},
		font = love.graphics.getFont()
	}
}

-- diagram fnc

function DiagramArea:plot(data)
	local object_tree = self.parser:parse(data)

	self.objects = {}

	local root_node = self:packNode(object_tree.root)

	self:add(root_node)

	collectgarbage("collect")
end

---@param node_list DumpedNode[]
---@return CompositeObject
function DiagramArea:packNodeList(node_list)
	if #node_list == 1 then
		return self:packNode(node_list[1])
	end

	local horizontal_container = self:create "DiagramHorizontalContainer" {}

	for _, node in ipairs(node_list) do
		local node_object = self:packNode(node)
		horizontal_container:add(node_object)
	end

	return horizontal_container
end

---@param node DumpedNode
---@return CompositeObject
---@protected
function DiagramArea:packNode(node)
	if not node.children then
		return self:makeNodeObject(node)
	end

	local vetical_container = self:create "DiagramVerticalContainer" {}

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

	local specific_node_descriptor = self:getObjectClass("DiagramNode" .. node_type_no_space)

	if specific_node_descriptor then
		return specific_node_descriptor{node}
	end

	return self:create "DiagramNode" {node}
end

function DiagramArea:new()
	self:setGrowth("horizontal")

	self.parser = TreeParser()
end

return DiagramArea