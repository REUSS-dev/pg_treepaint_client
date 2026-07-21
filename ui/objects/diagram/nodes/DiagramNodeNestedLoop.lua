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

	covered["Rows Removed by Filter"] = true
	covered["Filter"] = true

	if self.node.raw["Filter"] or self.node.raw["Rows Removed by Filter"] then
		local filter = self:create "SectionContainer" { title = "Filter Info" }
			:addTextProtected("Rows Removed by Filter: ", self.node.raw["Rows Removed by Filter"])
			:addTextProtected("Filter: ", self.node.raw["Filter"])

		sections[#sections+1] = filter
	end

	covered["Join Type"] = true
	covered["Inner Unique"] = true
	covered["Rows Removed by Join Filter"] = true
	covered["Join Filter"] = true

	local join_info = self:create "SectionContainer" { title = "Join Info" }
		:addTextProtected("Type: ", self.node.raw["Join Type"])
		:addTextProtected("Inner Unique: ", self.node.raw["Inner Unique"] ~= nil and tostring(self.node.raw["Inner Unique"]) )
		:addTextProtected("Join Relation: ", self.node.table)

	if self.node.raw["Rows Removed by Join Filter"] or self.node.raw["Join Filter"] then
		join_info:addText("")
			:addTextProtected("Rows Removed by Join Filter: ", self.node.raw["Rows Removed by Join Filter"])
			:addTextProtected("Join Filter: ", self.node.raw["Join Filter"])
	end

	sections[#sections+1] = join_info

	return sections
end

-- node fnc

function DiagramNodeNestedLoop:new()
	self.titleContainer:addDescProtected("JOIN on ", self.node.table, true)
end

return DiagramNodeNestedLoop