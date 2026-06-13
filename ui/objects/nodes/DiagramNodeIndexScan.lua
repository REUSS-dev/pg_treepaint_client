-- node

---@class DiagramNodeIndexScan : DiagramNode
local DiagramNodeIndexScan = {
	name = "DiagramNodeIndexScan",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.5, 1, 0.5, 1}
		}
	}
}

-- node fnc

function DiagramNodeIndexScan:new()
	self.titleContainer:createChild "Label" {
		font = self.desc_font,
		horizontal = "left",
		text = "on " .. self.node.table,
		textColor = {0.8, 0.8, 0.8, 1}
	}

	if self.node.loop_count then
		self.contentsContainer:createChild "Label" {
			font = self.font,
			text = "Loops: " .. self.node.loop_count
		}
	end
end

return DiagramNodeIndexScan