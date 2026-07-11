-- node

---@class DiagramNodeGather : DiagramNode
local DiagramNodeGather = {
	name = "DiagramNodeGather",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_GATHER
		}
	}
}

-- node fnc

function DiagramNodeGather:new()
	self.titleContainer:addDescProtected("Workers: ", self.node.raw["Workers Launched"] or self.node.raw["Workers Planned"], true)
end

return DiagramNodeGather