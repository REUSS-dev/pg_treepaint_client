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

	sections[1] = self:create "InfoPanelSection" { title = "Scan Info" }
		:addTextProtected("Schema: ", self.node.raw["Schema"])
		:addTextProtected("Relation: ", self.node.raw["Relation Name"])
		:addTextProtected("Alias: ", self.node.raw["Alias"])

	if self.node.raw["Filter"] then
		covered["Filter"] = true
		covered["Rows Removed by Filter"] = true
		
		sections[2] = self:create "InfoPanelSection" { title = "Filter Info" }
		:addTextProtected("Rows Removed by Filter: ", self.node.raw["Rows Removed by Filter"])
		:addTextProtected("Filter: ", self.node.raw["Filter"])
	end

	return sections
end

-- node fnc

function DiagramNodeSeqScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}
end

return DiagramNodeSeqScan