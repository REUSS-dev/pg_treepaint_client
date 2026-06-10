-- node

---@class DiagramNodeIndexOnlyScan : DiagramNode
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNode",
	default = {
		colors = {
			main = {32/255, 32/255, 32/255, 255/255},
			border = {0, 0.75, 0, 1},
			text = {1, 1, 1, 1}
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