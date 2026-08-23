-- node

---@class DiagramNodeSort : DiagramNode
local DiagramNodeSort = {
	name = "DiagramNodeSort",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_SORT
		}
	}
}

function DiagramNodeSort:populateInfo(covered)
	local sections = {}

	covered["Sort Method"] = true
	covered["Sort Space Used"] = true
	covered["Sort Space Type"] = true
	covered["Sort Key"] = true

	sections[1] = self:create "SectionContainer" { title = "node.Sort.section.title" }
		:addTextParametrized("node.Sort.section.method", self.node.raw["Sort Method"])

	if self.node.raw["Sort Space Used"] then
		local type_name = self:getObjectClass("Label").locale:rawget("node.Sort.space." .. self.node.raw["Sort Space Type"])

		sections[1]:addTextParametrized("node.Sort.section.space", {self.node.raw["Sort Space Used"], type_name or self.node.raw["Sort Space Type"]})
	end

	if self.node.raw["Sort Key"] then
		if #self.node.raw["Sort Key"] == 1 then
			sections[1]:addText("")
			           :addTextParametrized("node.Sort.section.order_by", self.node.raw["Sort Key"][1])
		elseif #self.node.raw["Sort Key"] > 1 then
			sections[1]:addText("")
			           :addTextParametrized("node.Sort.section.order_by_multiple", #self.node.raw["Sort Key"])
			           :addText(table.concat(self.node.raw["Sort Key"], ";\n"))
		end
	end

	return sections
end

-- node fnc

function DiagramNodeSort:new()
	if self.node.sort_method then
		local method_name = self:getObjectClass("Label").locale:rawget("node.Sort.method." .. self.node.sort_method)

		self.titleContainer:addDesc(type(method_name) == "string" and method_name or self.node.raw["Sort Method"], true)
	end


	self.contentsContainer:addTextParametrized("node.Sort.by", self.node.columns and (self.node.columns[1] .. (#self.node.columns > 1 and (", (+" .. (#self.node.columns - 1) .. ")") or "")))
end

return DiagramNodeSort