-- node

---@class DiagramNodeAggregate : DiagramNode
local DiagramNodeAggregate = {
	name = "DiagramNodeAggregate",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_AGGREGATE
		}
	}
}

function DiagramNodeAggregate:populateInfo(covered)
	local sections = {}

	covered["Strategy"] = true
	covered["Partial Mode"] = true
	covered["Planned Partitions"] = true
	covered["HashAgg Batches"] = true
	covered["Peak Memory Usage"] = true
	covered["Disk Usage"] = true
	covered["Group Key"] = true

	local locale = self:getObjectClass("Label").locale

	sections[1] = self:create "SectionContainer" { title = "node.Aggregate.section.title" }
		:addTextParametrized("node.Aggregate.section.strategy", self.node.raw["Strategy"] and locale:rawget("node.Aggregate.strategy." .. self.node.raw["Strategy"]) or self.node.raw["Strategy"])
		:addTextParametrized("node.Aggregate.section.partial", self.node.raw["Partial Mode"] and locale:rawget("node.Aggregate.partial_mode." .. self.node.raw["Partial Mode"]) or self.node.raw["Partial Mode"])
		:addTextParametrized("node.Aggregate.section.planned", self.node.raw["Planned Partitions"])
		:addTextParametrized("node.Aggregate.section.batches", self.node.raw["HashAgg Batches"])
		:addTextParametrized("node.Aggregate.section.peak", self.node.raw["Peak Memory Usage"])
		:addTextParametrized("node.Aggregate.section.disk", self.node.raw["Disk Usage"])

	if self.node.raw["Group Key"] then
		if #self.node.raw["Group Key"] == 1 then
			sections[1]:addText("")
			sections[1]:addTextParametrized("node.Aggregate.section.group_by", self.node.raw["Group Key"][1])
		elseif #self.node.raw["Group Key"] > 1 then
			sections[1]:addText("")
			sections[1]:addTextParametrized("node.Aggregate.section.group_by", "\n" .. table.concat(self.node.raw["Group Key"], ",\n"))
		end
	end

	return sections
end

-- node fnc

function DiagramNodeAggregate:new()
end

return DiagramNodeAggregate