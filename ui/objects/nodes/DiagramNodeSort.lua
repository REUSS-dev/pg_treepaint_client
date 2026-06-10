-- node

---@class DiagramNodeSort : DiagramNode
local DiagramNodeSort = {
	name = "DiagramNodeSort",
	extends = "DiagramNode",
	default = {
		colors = {
			main = {32/255, 32/255, 32/255, 255/255},
			border = {0, 0.75, 0.75, 1},
			text = {1, 1, 1, 1}
		}
	}
}

-- node fnc

function DiagramNodeSort:new()
	if self.node.sort_method then
		self.titleContainer:createChild "Label" {
			font = self.desc_font,
			horizontal = "left",
			text = self.node.sort_method,
			textColor = {0.8, 0.8, 0.8, 1}
		}
	end
end

return DiagramNodeSort