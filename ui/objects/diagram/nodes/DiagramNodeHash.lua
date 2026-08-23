-- node

---@class DiagramNodeHash : DiagramNode
local DiagramNodeHash = {
	name = "DiagramNodeHash",
	extends = "DiagramNode",
	default = {
		colors = {
			border = COLORS.NODE_HASH
		}
	}
}

function DiagramNodeHash:populateInfo(covered)
	local sections = {}

	covered["Hash Batches"] = true
	covered["Original Hash Batches"] = true
	covered["Hash Buckets"] = true
	covered["Original Hash Buckets"] = true
	covered["Peak Memory Usage"] = true

	local batches = self.node.raw["Hash Batches"]
	local batches_o = self.node.raw["Original Hash Batches"]

	local buckets = self.node.raw["Hash Buckets"]
	local buckets_o = self.node.raw["Original Hash Buckets"]

	local peak = self.node.raw["Peak Memory Usage"]

	if not (batches or buckets or peak) then
		return {}
	end

	local hash = self:create "SectionContainer" { title = "node.Hash.section.title" }

	if batches then
		if batches_o and batches ~= batches_o then
			hash:addTextParametrized("node.Hash.section.batches_o", {batches, batches_o})
		else
			hash:addTextParametrized("node.Hash.section.batches", batches)
		end
	end

	if batches then
		if batches_o and batches ~= batches_o then
			hash:addTextParametrized("node.Hash.section.buckets_o", {buckets, buckets_o})
		else
			hash:addTextParametrized("node.Hash.section.buckets", buckets)
		end
	end

	hash:addTextParametrized("node.Hash.section.peak", peak)

	sections[#sections+1] = hash

	return sections
end

-- node fnc

function DiagramNodeHash:new()
	if self.node.columns then
		self.contentsContainer:addText("node.Hash.columns")
		self.contentsContainer:addDesc(table.concat(self.node.columns, "\n"), true)
	end
end

return DiagramNodeHash