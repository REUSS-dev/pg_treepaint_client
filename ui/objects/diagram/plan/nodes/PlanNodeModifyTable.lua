-- node

---@class PlanNodeModifyTable : PlanNodeSeqScan
---@field PlanNodeSeqScan PlanNodeSeqScan
---@field PlanNode PlanNode
local PlanNodeModifyTable = {
	name = "PlanNodeModifyTable",
	extends = "PlanNode",
	default = {
		colors = {
			border = COLORS.NODE_BORDER
		}
	}
}

-- node fnc

function PlanNodeModifyTable:populateInfo(covered)
	local sections = {}

	covered["Schema"] = true
	covered["Relation Name"] = true
	covered["Alias"] = true
	covered["Operation"] = true

	sections[1] = self:create "SectionContainer" { title = "node.ModifyTable.section.title" }
		:addTextParametrized("node.ModifyTable.section.operation", self.node.raw["Operation"])
		:addDivider(nil, true)
		:addTextParametrized("node.ModifyTable.section.schema", self.node.raw["Schema"])
		:addTextParametrized("node.ModifyTable.section.relation", self.node.raw["Relation"])
		:addTextParametrized("node.ModifyTable.section.alias", self.node.raw["Relation Name"] ~= self.node.raw["Alias"] and self.node.raw["Alias"])

	return sections
end

function PlanNodeModifyTable:new()
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

	local op_name = self:getObjectClass("Label").locale:rawget("node.ModifyTable.operation." .. op)
	self.titleContainer:addDesc(type(op_name) == "string" and op_name or op, true)
end

return PlanNodeModifyTable