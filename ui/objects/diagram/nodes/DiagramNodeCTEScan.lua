-- node

---@class DiagramNodeCTEScan : DiagramNode
---@field DiagramNode DiagramNode
local DiagramNodeCTEScan = {
	name = "DiagramNodeCTEScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_CTE_SCAN
		}
	}
}

function DiagramNodeCTEScan:populateInfo(covered)
	local sections = {}

	covered["CTE Name"] = true
	covered["Alias"] = true

	sections[1] = self:create "SectionContainer" { title = "node.CTEScan.section.title" }
		:addTextParametrized("node.CTEScan.section.cte", self.node.raw["CTE Name"])
		:addTextParametrized("node.CTEScan.section.alias", self.node.raw["Alias"])

	return sections
end

function DiagramNodeCTEScan:generateNavigationObjects()
	self.DiagramNode.generateNavigationObjects(self)

	local cte_name = self.node.raw["CTE Name"]
	if not cte_name then
		return
	end

	cte_name = "CTE " .. cte_name

	local cte_node = self.diagram.cte_list[cte_name]
	if not cte_node then
		return
	end

	local cte_navigation = self:createChild "DiagramNodeNavigation" {
		pointer = cte_node,
		style = "Left"
	}
	cte_navigation:createText("node.CTEScan.jump")
	cte_navigation:hide()

	cte_navigation.x = math.floor((self.w - cte_navigation.w)/2 + .5)
	cte_navigation.y = self.h + self.bsize * 2 + self.NAV_OFFSET

	self.navigation.right[#self.navigation.right+1] = cte_navigation
	self.navigation[#self.navigation+1] = cte_navigation
end

-- node fnc

function DiagramNodeCTEScan:new()
	if self.node.raw["CTE Name"] then
		if self.node.raw["Alias"] and self.node.raw["Alias"] ~= self.node.raw["CTE Name"] then
			self.titleContainer:addDescParametrized("node.CTEScan.on_cte_alias", {self.node.raw["CTE Name"], self.node.raw["Alias"]})
		else
			self.titleContainer:addDescParametrized("node.CTEScan.on_cte", self.node.raw["CTE Name"])
		end
	end
end

return DiagramNodeCTEScan