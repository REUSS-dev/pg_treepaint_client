-- node

---@class PlanNodeBitmapOr : PlanNode
local PlanNodeBitmapOr = {
	name = "PlanNodeBitmapOr",
	extends = "PlanNode",
	default = {
		colors = {
			border = COLORS.NODE_BITMAPOR
		}
	}
}

-- node fnc

function PlanNodeBitmapOr:new()
end

return PlanNodeBitmapOr