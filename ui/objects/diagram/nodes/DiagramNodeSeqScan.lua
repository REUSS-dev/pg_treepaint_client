-- node

---@class DiagramNodeSeqScan : DiagramNode
local DiagramNodeSeqScan = {
	name = "DiagramNodeSeqScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_SEQ_SCAN
		}
	}
}

function DiagramNodeSeqScan:populateInfo(covered)
	local sections = {}

	covered["Schema"] = true
	covered["Relation Name"] = true
	covered["Alias"] = true
	covered["Rows Removed by Filter"] = true
	covered["Filter"] = true

	sections[1] = self:create "SectionContainer" { title = "Scan Info" }
		:addTextProtected("Schema: ", self.node.raw["Schema"])
		:addTextProtected("Relation: ", self.node.raw["Relation Name"])
		:addTextProtected("Alias: ", self.node.raw["Alias"])
		:addTextProtected("Rows Removed by Filter: ", self.node.raw["Rows Removed by Filter"])
		:addTextProtected("Filter: ", self.node.raw["Filter"])

	return sections
end

-- node fnc

function DiagramNodeSeqScan:new()
	self.titleContainer:addDescProtected("on ", self.node.table, true)
end

return DiagramNodeSeqScan