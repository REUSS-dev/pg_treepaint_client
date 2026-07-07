-- node

---@class DiagramNodeIndexScan : DiagramNodeIndexOnlyScan
local DiagramNodeIndexScan = {
	name = "DiagramNodeIndexScan",
	extends = "DiagramNodeIndexOnlyScan",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_SCAN
		}
	}
}

-- node fnc

function DiagramNodeIndexScan:new()
	if self.node.loop_count then
		self.contentsContainer:createChild "Label" {
			w = "fill",
			font = self.font,
			text = "Loops: " .. self.node.loop_count,
			textColor = self.text_color
		}
	end
end

return DiagramNodeIndexScan