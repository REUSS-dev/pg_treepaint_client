-- node

---@class DiagramNodeHash : DiagramNode
local DiagramNodeHash = {
	name = "DiagramNodeHash",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.75, 0, 0.75, 1}
		}
	}
}

-- node fnc

function DiagramNodeHash:new()
	if self.node.columns then
		self.contentsContainer:createChild "Label" {
			font = self.font,
			horizontal = "left",
			text = "Columns"
		}
	
		self.contentsContainer:createChild "Label" {
			font = self.desc_font,
			horizontal = "left",
			text = table.concat(self.node.columns, "\n"),
			textColor = {0.8, 0.8, 0.8, 1}
		}
	end
end

return DiagramNodeHash