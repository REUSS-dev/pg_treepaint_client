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

	local hash = self:create "InfoPanelSection" { title = "Hash Info" }
		:addTextProtected("Batches: ", batches and (batches_o and batches~=batches_o and (batches .. " (Original: " .. batches_o .. ")") or batches))
		:addTextProtected("Buckets: ", buckets and (buckets_o and buckets~=buckets_o and (buckets .. " (Original: " .. buckets_o .. ")") or buckets))
		:addTextProtected("Peak memory usage: ", peak and (peak .. "kB"))

	sections[#sections+1] = hash

	return sections
end

-- node fnc

function DiagramNodeHash:new()
	if self.node.columns then
		self.contentsContainer:addText("Columns")
		self.contentsContainer:addDesc(table.concat(self.node.columns, "\n"), true)
	end
end

return DiagramNodeHash