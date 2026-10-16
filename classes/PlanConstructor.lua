-- PlanConstructor

local PLAN_NODE_PREFIX = "PlanNode"

---@class PlanConstructor
---@field diagram DiagramArea
local PlanConstructor = {}
PlanConstructor.__index = PlanConstructor

---@param root_node DumpedNode
function PlanConstructor:generate(root_node)
    return self:packChild(root_node)
end

---@param node_list DumpedNode[]
function PlanConstructor:packNodeList(node_list)
	if #node_list == 1 then
		return self:packChild(node_list[1])
	end

	---@type DiagramHorizontalContainer
	local horizontal_container  = self:create "DiagramHorizontalContainer" { diagram = self.diagram }

	for _, node in ipairs(node_list) do
		local node_object = self:packChild(node)
		horizontal_container:add(node_object)
	end

	return horizontal_container
end

---@param node DumpedNode
---@protected
function PlanConstructor:packChild(node)
	local packed = self:packNode(node)

	if node.relationship ~= "InitPlan" and node.relationship ~= "Subquery" and node.relationship ~= "SubPlan" then
		return packed
	end

	local subplan_container

	if node.relationship == "InitPlan" then
		subplan_container = self:create "DiagramSubplanContainer" { title = node.subplan, diagram = self.diagram }
			:pack(packed)

		if packed.name == "DiagramVerticalContainer" then
			self.diagram.cte_list[node.subplan] = packed.master
		else ---@cast packed PlanNode
			self.diagram.cte_list[node.subplan] = packed
		end
	end

	if node.relationship == "Subquery" then
		self.diagram.subquery_counter = self.diagram.subquery_counter + 1

		local subquery_title = self:getObjectClass("Label").locale:format("plan.subquery", {self.diagram.subquery_counter})

		subplan_container = self:create "DiagramSubplanContainer" { title = subquery_title, diagram = self.diagram }
			:pack(packed)
	end

	if node.relationship == "SubPlan" then
		subplan_container = self:create "DiagramSubplanContainer" { title = node.subplan, diagram = self.diagram }
			:pack(packed)
	end

	self.diagram.subplanContainers[#self.diagram.subplanContainers+1] = subplan_container

	return subplan_container
end

---@param node DumpedNode
---@protected
function PlanConstructor:packNode(node)
	if not node.children then
		return self:makeNode(node)
	end

	---@type DiagramVerticalContainer
	local vetical_container = self:create "DiagramVerticalContainer" { diagram = self.diagram }

	local node_object = self:makeNode(node)
	vetical_container:add(node_object)

	local children_object = self:packNodeList(node.children)

	if node_object.nodeType == "Gather" or node_object.nodeType == "Gather Merge" then
		---@cast children_object DiagramNode|DiagramVerticalContainer
		local worker_count = node_object.node.raw["Workers Launched"] or node_object.node.raw["Workers Planned"]

		local gather_title = worker_count and self:getObjectClass("Label").locale:format("plan.gather.additional_workers", {worker_count}) or "plan.gather.parallelized"

		local subplan_container = self:create "DiagramSubplanContainer" { title = gather_title, diagram = self.diagram, kind = "workers" }
			:pack(children_object)

		self.diagram.subplanContainers[#self.diagram.subplanContainers+1] = subplan_container

		vetical_container:add(subplan_container)
		return vetical_container
	end

	vetical_container:add(children_object)

	return vetical_container
end

---@param node DumpedNode
---@return PlanNode
---@protected
function PlanConstructor:makeNode(node)
	local node_type_no_space = string.gsub(node.type, " ", "")

	local specific_node_descriptor = self:getObjectClass(PLAN_NODE_PREFIX .. node_type_no_space) or self:getObjectClass(PLAN_NODE_PREFIX)

	return specific_node_descriptor {
		node,
		diagram = self.diagram
	}
end

---@private
function PlanConstructor:create(...)
    return self.diagram:create(...)
end

---@private
function PlanConstructor:getObjectClass(...)
    return self.diagram:getObjectClass(...)
end

function PlanConstructor:new(diagram)
    assert(diagram and diagram.name == "DiagramArea", "DiagramArea object is required for PlanConstructor")

	local new_constructor = {
        diagram = diagram
    }

	setmetatable(new_constructor, PlanConstructor)

	return new_constructor
end

setmetatable(PlanConstructor, {__call = PlanConstructor.new})

return PlanConstructor