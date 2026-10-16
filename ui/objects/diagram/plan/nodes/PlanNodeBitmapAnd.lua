-- node

---@class PlanNodeBitmapAnd : PlanNode
local PlanNodeBitmapAnd = {
	name = "PlanNodeBitmapAnd",
	extends = "PlanNode",
	default = {
		colors = {
			border = COLORS.NODE_BITMAPAND
		}
	}
}

-- node fnc

function PlanNodeBitmapAnd:new()
end

return PlanNodeBitmapAnd