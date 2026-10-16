-- query node

---@class QueryNode : DiagramNode
---@field DiagramNode DiagramNode
---@field node Query
local QueryNode = {
	name = "QueryNode",
	extends = "DiagramNode",
	rules = {
		{{1, "node"}, "node"},
	},
	default = {
	},
}

function QueryNode:buildTitleContainer()
	if not self.node.name then
		self.titleContainer:createChild "Label" {
			w = "fill",
			font = self.font.M,
			horizontal = "left",
			text = self.node.type,
			textColor = self.text_color,
			no_locale = true,
		}

		return
	end

	self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = self.node.name,
		textColor = self.text_color,
		no_locale = true,
	}
	self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = self.node.type,
		textColor = self.text_color_desc,
		no_locale = true,
	}
end

-- node fnc

function QueryNode:new()
	assert(self.node, "QueryNode object must be initialized with a Query object")

	self.nodeType = self.node.type

	self:buildTitleContainer()
end

return QueryNode