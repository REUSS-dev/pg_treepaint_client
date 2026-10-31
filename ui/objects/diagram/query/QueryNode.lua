-- query node

---@class QueryNode : DiagramNode
---@field DiagramNode DiagramNode
---@field query Query
---@field nodeType NodeType
local QueryNode = {
	name = "QueryNode",
	extends = "DiagramNode",
	rules = {
		{{1, "query"}, "query"},
	},
	default = {
	},
}

function QueryNode:buildTitleContainer()
	if not self.query.name then
		self.titleContainer:createChild "Label" {
			w = "fill",
			font = self.font.M,
			horizontal = "left",
			text = self.query.type,
			textColor = self.text_color,
		}

		return
	end

	self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = self.query.type,
		textColor = self.text_color,
	}
	self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = self.query.name,
		textColor = self.text_color_desc,
	}
end

-- node fnc

function QueryNode:new()
	assert(self.query, "QueryNode object must be initialized with a Query object")

	self.nodeType = self.query.type

	self:buildTitleContainer()
end

return QueryNode