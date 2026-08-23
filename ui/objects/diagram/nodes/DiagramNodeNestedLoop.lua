-- node

---@class DiagramNodeNestedLoop : DiagramNode
local DiagramNodeNestedLoop = {
	name = "DiagramNodeNestedLoop",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_NESTED_LOOP
		}
	}
}

function DiagramNodeNestedLoop:populateInfo(covered)
	local sections = {}

	covered["Join Type"] = true
	covered["Inner Unique"] = true

	local join_info = self:create "SectionContainer" { title = "node.NestedLoop.section.title" }

	if self.node.raw["Join Type"] then
		local join_type = self:getObjectClass("Label").locale:rawget("node.NestedLoop.join_type." .. self.node.raw["Join Type"])

		join_info:addTextParametrized("node.NestedLoop.section.type", type(join_type) == "string" and join_type or self.node.raw["Join Type"])
	end

	join_info
		:addTextParametrized("node.NestedLoop.section.inner_unique", self.node.raw["Inner Unique"] ~= nil and tostring(self.node.raw["Inner Unique"]))
		:addTextParametrized("node.NestedLoop.section.relation", self.node.table)

	sections[#sections+1] = join_info

	return sections
end

-- node fnc

function DiagramNodeNestedLoop:new()
	self.titleContainer:addDescParametrized("node.NestedLoop.on", self.node.table, true)
end

return DiagramNodeNestedLoop