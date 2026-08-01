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

	sections[1] = self:create "SectionContainer" { title = "Aggregate Info" }
		:addTextProtected("Strategy: ", self.node.raw["Strategy"])
		:addTextProtected("Partial Mode: ", self.node.raw["Partial Mode"])
		:addTextProtected("Planned Partitions: ", self.node.raw["Planned Partitions"])
		:addTextProtected("HashAgg Batches: ", self.node.raw["HashAgg Batches"])
		:addTextProtected("Peak Memory Usage: ", self.node.raw["Peak Memory Usage"] and (self.node.raw["Peak Memory Usage"] .. " kB"))
		:addTextProtected("Disk Usage: ", self.node.raw["Disk Usage"] and (self.node.raw["Disk Usage"] .. " kB"))

	if self.node.raw["Group Key"] then
		if #self.node.raw["Group Key"] == 1 then
			sections[1]:addText("")
			sections[1]:addText("Group by: " .. self.node.raw["Group Key"][1])
		elseif #self.node.raw["Group Key"] > 1 then
			sections[1]:addText("")
			sections[1]:addText("Group by:\n" .. table.concat(self.node.raw["Group Key"], ",\n"))
		end
	end

	return sections
end

-- node fnc

function DiagramNodeAggregate:new()
end

return DiagramNodeAggregate