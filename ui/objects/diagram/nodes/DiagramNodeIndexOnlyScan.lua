-- ui/objects/nodes/DiagramNodeIndexOnlyScan.lua

---@class DiagramNodeIndexOnlyScan : DiagramNodeSeqScan
---@field DiagramNodeSeqScan DiagramNodeSeqScan
local DiagramNodeIndexOnlyScan = {
	name = "DiagramNodeIndexOnlyScan",
	extends = "DiagramNodeSeqScan",
	default = {
		colors = {
			border = COLORS.NODE_INDEX_ONLY_SCAN
		}
	}
}

function DiagramNodeIndexOnlyScan:populateInfo(covered)
	local sections = self.DiagramNodeSeqScan.populateInfo(self, covered)

	covered["Index Name"] = true
	covered["Scan Direction"] = true
	covered["Index Searches"] = true
	covered["Heap Fetches"] = true

	sections[#sections+1] = self:create "SectionContainer" { title = "node.IndexOnlyScan.section.title" }
		:addTextParametrized("node.IndexOnlyScan.section.index", self.node.raw["Index Name"])
		:addTextParametrized("node.IndexOnlyScan.section.direction", self.node.raw["Scan Direction"])
		:addTextParametrized("node.IndexOnlyScan.section.searches", self.node.raw["Index Searches"])
		:addTextParametrized("node.IndexOnlyScan.section.heap", self.node.raw["Heap Fetches"])
		:addTextParametrized("node.IndexOnlyScan.section.condition", self.node.raw["Index Cond"])

	return sections
end

-- node fnc

function DiagramNodeIndexOnlyScan:new()
	self.contentsContainer:addTextParametrized("node.IndexOnlyScan.loops", self.node.loop_count and (self.node.loop_count > 1) and self.node.loop_count)
end

return DiagramNodeIndexOnlyScan


