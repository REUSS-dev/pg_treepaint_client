-- node

---@class DiagramNodeHash : DiagramNode
local DiagramNodeHash = {
	name = "DiagramNodeHash",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_HASH
		}
	}
}

-- node fnc

function DiagramNodeHash:new()
	if self.node.columns then
		self.contentsContainer:addText("Columns")
		self.contentsContainer:addDesc(table.concat(self.node.columns, "\n"), true)
	end
end

return DiagramNodeHash