-- node

---@class DiagramNodeUnique : DiagramNode
local DiagramNodeUnique = {
	name = "DiagramNodeUnique",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_UNIQUE
		}
	}
}

-- node fnc

function DiagramNodeUnique:new()
end

return DiagramNodeUnique