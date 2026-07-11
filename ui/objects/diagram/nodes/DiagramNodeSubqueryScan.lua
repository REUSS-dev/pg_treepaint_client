-- node

---@class DiagramNodeSubqueryScan : DiagramNodeSeqScan
---@field DiagramNodeSeqScan DiagramNodeSeqScan
---@field DiagramNode DiagramNode
local DiagramNodeSubqueryScan = {
	name = "DiagramNodeSubqueryScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_SUBQUERY_SCAN
		}
	}
}

-- node fnc

function DiagramNodeSubqueryScan:new()
	self.titleContainer:addDescProtected("", self.node.raw["Alias"], true)
end

return DiagramNodeSubqueryScan