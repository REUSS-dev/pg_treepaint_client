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
	covered["Schema"] = true
	covered["Relation Name"] = true
	covered["Alias"] = true

	return self:create "InfoPanelSection" { title = "Scan Info" }
		:addTextProtected("Schema: ", self.node.raw["Schema"])
		:addTextProtected("Relation: ", self.node.raw["Relation Name"])
		:addTextProtected("Alias: ", self.node.raw["Alias"])
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