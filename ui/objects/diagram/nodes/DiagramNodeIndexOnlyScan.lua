-- ui/objects/nodes/DiagramNodeIndexOnlyScan.lua

---@class DiagramNodeIndexOnlyScan : DiagramNode
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_ONLY_SCAN
		}
	}
}

function DiagramNodeIndexOnlyScan:populateInfo(covered)
	local sections = {}

	covered["Schema"] = true
	covered["Relation Name"] = true
	covered["Alias"] = true
	covered["Index Name"] = true
	covered["Scan Direction"] = true
	covered["Index Searches"] = true
	covered["Rows Removed by Index Recheck"] = true
	covered["Index Cond"] = true

	sections[#sections+1] = self:create "InfoPanelSection" { title = "Scan Info" }
		:addTextProtected("Schema: ", self.node.raw["Schema"])
		:addTextProtected("Relation: ", self.node.raw["Relation Name"])
		:addTextProtected("Alias: ", self.node.raw["Alias"])

	sections[#sections+1] = self:create "InfoPanelSection" { title = "Index Info" }
		:addTextProtected("Index: ", self.node.raw["Index Name"])
		:addTextProtected("Scan Direction: ", self.node.raw["Scan Direction"])
		:addTextProtected("Index Searches: ", self.node.raw["Index Searches"])
		:addTextProtected("Rows Removed by Recheck: ", self.node.raw["Rows Removed by Index Recheck"])
		:addTextProtected("Condition:\n", self.node.raw["Index Cond"])

	return sections
end

-- node fnc

function DiagramNodeIndexOnlyScan:new()
	self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = self.text_color_desc
	}
end

return DiagramNodeIndexOnlyScan


