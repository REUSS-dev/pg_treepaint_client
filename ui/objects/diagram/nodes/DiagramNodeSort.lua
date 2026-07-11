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

	sections[1] = self:create "InfoPanelSection" { title = "Sort Info" }
		:addTextProtected("Method: ", self.node.sort_method)
		:addTextProtected("Space Used: ", self.node.raw["Sort Space Used"] and (self.node.raw["Sort Space Used"] .. " kB (" .. self.node.raw["Sort Space Type"] .. ")") or nil)

	if self.node.raw["Sort Key"] then
		if #self.node.raw["Sort Key"] == 1 then
			sections[1]:addText("")
			sections[1]:addText("Order by: " .. self.node.raw["Sort Key"][1])
		elseif #self.node.raw["Sort Key"] > 1 then
			sections[1]:addText("")
			sections[1]:addText("Order by:\n" .. table.concat(self.node.raw["Sort Key"], ",\n"))
		end
	end

	return sections
end

-- node fnc

function DiagramNodeSort:new()
	self.titleContainer:addDescProtected("", self.node.sort_method, true)

	self.contentsContainer:addTextProtected("by ", self.node.columns and (self.node.columns[1] .. (#self.node.columns > 1 and (", (+" .. (#self.node.columns - 1) .. ")") or "")))
end

return DiagramNodeSort