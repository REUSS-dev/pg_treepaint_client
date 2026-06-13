-- ui/objects/nodes/DiagramNodeIndexOnlyScan.lua

---@class DiagramNodeIndexOnlyScan : DiagramNode
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0, 0.75, 0, 1}
		}
	}
}

-- node fnc

function DiagramNodeIndexOnlyScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = {0.8, 0.8, 0.8, 1}
	}
end

return DiagramNodeIndexOnlyScan


