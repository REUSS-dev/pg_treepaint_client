-- node

---@class DiagramNodeAggregate : DiagramNode
local DiagramNodeAggregate = {
	name = "DiagramNodeAggregate",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_AGGREGATE
		}
	}
}

-- node fnc

function DiagramNodeAggregate:new()
end

return DiagramNodeAggregate