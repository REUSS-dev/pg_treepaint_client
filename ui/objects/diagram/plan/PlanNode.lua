-- plan node

---@class PlanNode : DiagramNode
---@field DiagramNode DiagramNode
---@field node DumpedNode
---@field nodeType NodeType
local PlanNode = {
	name = "PlanNode",
	extends = "DiagramNode",
	rules = {
		{{1, "node"}, "node"},
	},
	default = {
	},
}

function PlanNode:buildTitleContainer()
	if not self.node.rows or self.node.loop_count == 0 then
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

	local titlebox = self.titleContainer:createChild "Container" {
		w = "fill",
		growth = "horizontal",
		vertical = "top",
		gap = 10,
	}

	titlebox:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = self.node.type,
		textColor = self.text_color,
		no_locale = true,
	}

	titlebox:createChild "Label" {
		font = self.font.S,
		horizontal = "right",
		text = self.node.rows,
		textColor = self.text_color_desc,
		no_locale = true,
	}
end

-- node fnc

function PlanNode:new()
	assert(self.node, "PlanNode object must be initialized with a DumpedNode object")

	local node_data = self.node
	self.nodeType = self.node.type

	-- Children

	self:buildTitleContainer()

	if node_data.timing then
		if node_data.raw["Actual Loops"] == 0 then
			self.footerContainer:createChild "Label" {
				w = "fill",
				font = self.font.S,
				horizontal = "right",
				textColor = self.text_color_desc,
				text = "node.time_never_executed",
			}
		elseif node_data.workers then
			self.footerContainer:createChild "Label" {
				w = "fill",
				font = self.font.S,
				horizontal = "right",
				textColor = self.text_color_desc,
				text = "node.time_workers",
				with = {node_data.timing.node.total[2], node_data.workers}
			}
		else
			self.footerContainer:createChild "Label" {
				w = "fill",
				font = self.font.S,
				horizontal = "right",
				textColor = self.text_color_desc,
				text = "node.time",
				with = {node_data.timing.node.total[2]}
			}
		end
	elseif node_data.startup_cost then
		self.footerContainer:createChild "Label" {
			w = "fill",
			font = self.font.S,
			horizontal = "right",
			textColor = self.text_color_desc,
			text = "node.time_cost",
			with = {node_data.startup_cost, node_data.total_cost}
		}
	end
end

return PlanNode