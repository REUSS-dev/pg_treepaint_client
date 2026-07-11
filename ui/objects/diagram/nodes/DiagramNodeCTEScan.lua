-- node

---@class DiagramNodeCTEScan : DiagramNodeSeqScan
---@field DiagramNodeSeqScan DiagramNodeSeqScan
---@field DiagramNode DiagramNode
local DiagramNodeCTEScan = {
	name = "DiagramNodeCTEScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_CTE_SCAN
		}
	}
}

function DiagramNodeCTEScan:populateInfo(covered)
	local sections = self.DiagramNodeSeqScan.populateInfo(self, covered)

	covered["CTE Name"] = true

	sections[1]:addTextProtected("CTE Name: ", self.node.raw["CTE Name"])

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
	cte_navigation:createText("Jump to CTE")
	cte_navigation:hide()

	cte_navigation.x = math.floor((self.w - cte_navigation.w)/2 + .5)
	cte_navigation.y = self.h + self.bsize * 2 + self.NAV_OFFSET

	self.navigation.right[#self.navigation.right+1] = cte_navigation
	self.navigation[#self.navigation+1] = cte_navigation
end

-- node fnc

function DiagramNodeCTEScan:new()
	self.titleContainer:addDescProtected("on CTE ", self.node.raw["CTE Name"] and (self.node.raw["CTE Name"] .. (self.node.raw["Alias"] and (" (" .. self.node.raw["Alias"] .. ")") or "")), true)
end

return DiagramNodeCTEScan