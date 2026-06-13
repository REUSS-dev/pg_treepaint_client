-- node

---@class DiagramNodeSeqScan : DiagramNode
local DiagramNodeSeqScan = {
	name = "DiagramNodeSeqScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.75, 0.1, 0.1, 1}
		}
	}
}

-- node fnc

function DiagramNodeSeqScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = {0.8, 0.8, 0.8, 1}
	}
end

return DiagramNodeSeqScan