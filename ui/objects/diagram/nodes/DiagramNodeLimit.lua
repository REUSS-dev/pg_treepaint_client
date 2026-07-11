-- node

---@class DiagramNodeLimit : DiagramNode
local DiagramNodeLimit = {
	name = "DiagramNodeLimit",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_LIMIT
		}
	}
}

-- node fnc

function DiagramNodeLimit:new()
end

return DiagramNodeLimit