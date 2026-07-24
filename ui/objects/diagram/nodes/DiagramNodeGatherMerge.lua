-- node

---@class DiagramNodeGatherMerge : DiagramNodeGather
local DiagramNodeGatherMerge = {
	name = "DiagramNodeGatherMerge",
	extends = "DiagramNodeGather",
	default = {
		colors = {
			border = COLORS.NODE_GATHER_MERGE
		}
	}
}

-- node fnc

function DiagramNodeGatherMerge:new()
end

return DiagramNodeGatherMerge