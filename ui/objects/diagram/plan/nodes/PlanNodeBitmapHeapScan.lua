-- node

---@class PlanNodeBitmapHeapScan : PlanNode
---@field PlanNodeSeqScan PlanNodeSeqScan
local PlanNodeBitmapHeapScan = {
	name = "PlanNodeBitmapHeapScan",
	extends = "PlanNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_BITMAP_HEAP_SCAN
		}
	}
}

function PlanNodeBitmapHeapScan:populateInfo(covered)
	local sections = self.PlanNodeSeqScan.populateInfo(self, covered)
	local scan_info = sections[1]

	covered["Exact Heap Blocks"] = true
	covered["Lossy Heap Blocks"] = true

	if (not self.node.raw["Exact Heap Blocks"] or self.node.raw["Exact Heap Blocks"] == 0) and (not self.node.raw["Lossy Heap Blocks"] or self.node.raw["Lossy Heap Blocks"] == 0) then
		return sections
	end

	scan_info:addDivider(nil, true)
	scan_info:addTextParametrized("node.BitmapHeapScan.section.exact", self.node.raw["Exact Heap Blocks"] and self.node.raw["Exact Heap Blocks"] ~= 0 and self.node.raw["Exact Heap Blocks"])
	scan_info:addTextParametrized("node.BitmapHeapScan.section.lossy", self.node.raw["Lossy Heap Blocks"] and self.node.raw["Lossy Heap Blocks"] ~= 0 and self.node.raw["Lossy Heap Blocks"])

	return sections
end

-- node fnc

function PlanNodeBitmapHeapScan:new()
end

return PlanNodeBitmapHeapScan