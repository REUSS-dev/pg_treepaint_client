-- node

---@class DiagramNodeGather : DiagramNode
local DiagramNodeGather = {
	name = "DiagramNodeGather",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_GATHER
		}
	}
}

function DiagramNodeGather:populateInfo(covered)
	local sections = {}

	covered["Workers Planned"] = true
	covered["Workers Launched"] = true

	local gather_section = self:create "SectionContainer" { title = "node.Gather.section.title" }
	sections[#sections+1] = gather_section

	if self.node.raw["Workers Launched"] and self.node.raw["Workers Planned"] then
		gather_section:addTextParametrized("node.Gather.section.workers_combined", {self.node.raw["Workers Launched"], self.node.raw["Workers Planned"]})

		return sections
	end

	gather_section
		:addTextParametrized("node.Gather.section.workers_launched", self.node.raw["Workers Launched"])
		:addTextParametrized("node.Gather.section.workers_planned", self.node.raw["Workers Planned"])

	return sections
end

-- node fnc

function DiagramNodeGather:new()
	self.titleContainer:addDescParametrized("node.Gather.workers", self.node.raw["Workers Launched"] or self.node.raw["Workers Planned"], true)
end

return DiagramNodeGather