-- node

---@class DiagramNodeBitmapHeapScan : DiagramNode
---@field DiagramNodeIndexOnlyScan DiagramNodeIndexOnlyScan
local DiagramNodeBitmapHeapScan = {
	name = "DiagramNodeBitmapHeapScan",
	extends = "DiagramNodeIndexOnlyScan",
	default = {
		colors = {
			border = COLORS.NODE_BITMAP_HEAP_SCAN
		}
	}
}

function DiagramNodeBitmapHeapScan:populateInfo(covered)
	local sections = self.DiagramNodeIndexOnlyScan.populateInfo(self, covered)
	local scan_info = sections[1]
	local index_info = sections[#sections]

	covered["Exact Heap Blocks"] = true
	covered["Lossy Heap Blocks"] = true

	scan_info:addTextProtected("Exact Heap Blocks: ", self.node.raw["Exact Heap Blocks"] and self.node.raw["Exact Heap Blocks"] ~= 0 and self.node.raw["Exact Heap Blocks"])
	scan_info:addTextProtected("Lossy Heap Blocks: ", self.node.raw["Lossy Heap Blocks"] and self.node.raw["Lossy Heap Blocks"] ~= 0 and self.node.raw["Lossy Heap Blocks"])

	covered["Recheck Cond"] = true

	index_info:addTextProtected("Recheck condition: ", self.node.raw["Recheck Cond"])

	return sections
end

-- node fnc

function DiagramNodeBitmapHeapScan:new()
end

return DiagramNodeBitmapHeapScan