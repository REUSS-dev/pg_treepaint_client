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

	sections[1] = self:create "SectionContainer" { title = "node.SeqScan.section.title" }
		:addTextParametrized("node.SeqScan.section.schema", self.node.raw["Schema"])
		:addTextParametrized("node.SeqScan.section.relation", self.node.raw["Relation Name"])
		:addTextParametrized("node.SeqScan.section.alias", self.node.raw["Relation Name"] ~= self.node.raw["Alias"] and self.node.raw["Alias"])

	return sections
end

-- node fnc

function DiagramNodeSeqScan:new()
	self.titleContainer:addDescParametrized("node.SeqScan.on", self.node.table, true)
end

return DiagramNodeSeqScan