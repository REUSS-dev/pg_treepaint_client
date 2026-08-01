-- node

---@class DiagramNodeModifyTable : DiagramNodeSeqScan
---@field DiagramNodeSeqScan DiagramNodeSeqScan
---@field DiagramNode DiagramNode
local DiagramNodeModifyTable = {
	name = "DiagramNodeModifyTable",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_BORDER
		}
	}
}

-- node fnc

function DiagramNodeModifyTable:populateInfo(covered)
	local sections = {}

	covered["Schema"] = true
	covered["Relation Name"] = true
	covered["Alias"] = true
	covered["Operation"] = true

	sections[1] = self:create "SectionContainer" { title = "Modify Info" }
		:addTextProtected("Operation: ", self.node.raw["Operation"])
		:addDivider(nil, true)
		:addTextProtected("Schema: ", self.node.raw["Schema"])
		:addTextProtected("Relation: ", self.node.raw["Relation Name"])
		:addTextProtected("Alias: ", self.node.raw["Relation Name"] ~= self.node.raw["Alias"] and self.node.raw["Alias"] or nil)

	return sections
end

function DiagramNodeModifyTable:new()
	local op = self.node.raw["Operation"]

	if not op then
		return
	end

	if op == "Insert" then
		self.palette:setColor(3, COLORS.QUERY_INSERT)
	elseif op == "Update" then
		self.palette:setColor(3, COLORS.QUERY_UPDATE)
	elseif op == "Delete" then
		self.palette:setColor(3, COLORS.QUERY_DELETE)
	end

	self.titleContainer:addDesc(self.node.raw["Operation"], true)
end

return DiagramNodeModifyTable