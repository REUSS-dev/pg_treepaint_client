-- node

---@class DiagramNodeAggregate : DiagramNode
local DiagramNodeAggregate = {
	name = "DiagramNodeAggregate",
	extends = "DiagramNode",
	default = {
		colors = {
			border = {0.75, 0.5, 0, 1}
		}
	}
}

-- node fnc

function DiagramNodeAggregate:new()
end

return DiagramNodeAggregate