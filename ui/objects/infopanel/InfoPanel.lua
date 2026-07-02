-- InfoPanel

-- config

local CACHE_SIZE = 5

---@class InfoPanel : CompositeObject
---@field font string
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field head InfoPanelHead
---@field cacheStorage table<DiagramNode, CompositeObject[]>
local InfoPanel = {
	name = "InfoPanel",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"}
	},
	default = {
		w = 400,
		h = "fill",
		growth = "vertical",
		vertical = "top",
		padding = 15,

		color = COLORS.INFO_PANEL
	},

	opaque = true
}

---Display specific node information on info panel
---@param node DiagramNode
function InfoPanel:displayNode(node)
	if not self.cacheStorage[node] then
		self:createContents(node)
	end

	self:setNodeInfo(node)
	--self.contentsContainer.objects = self.cacheStorage[node]
	self.contentsContainer:relayout()

	self:show()
end

---@param node DiagramNode
function InfoPanel:setNodeInfo(node)
	self.head:setNode(node)
end

---@param node DiagramNode
function InfoPanel:createContents(node)
	
end

function InfoPanel:new()
	self.cacheStorage = {}

	-- Head
	self.head = self:createChild "InfoPanelHead" {
		font = self.font
	}

	self.contentsContainer = self:createChild "Container" { gap = 5, horizontal = "left", w = "fill" }
	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self:hide()
end

return InfoPanel