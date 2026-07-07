-- InfoPanelHead

---@class InfoPanelHead : CompositeObject
---@field picture InfoPanelPicture
---@field nameLabel Label
---@field parentLabel Label
---@field childrenLabel Label
---@field font string
local InfoPanelHead = {
	name = "InfoPanelHead",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"}
	},
	default = {
		w = "fill",
		h = "hug",
		growth = "horizontal",
		gap = 10,
		horizontal = "left",
		vertical = "top"
	},
}

---Sets node info in head
---@param node DiagramNode
function InfoPanelHead:setNode(node)
	-- 1 - picture
	self.picture:setNode(node)

	-- 2 - Type name
	self.nameLabel:setText(node.nodeType)

	-- 3 & 4 - Parent and children
	self:setParent(node)
	self:setChildren(node)
end

---@param node DiagramNode
function InfoPanelHead:setParent(node)
	local parent = node:getParentNode()

	if not parent then
		self.parentLabel:hide()
		return
	end

	self.parentLabel:setText("Parent: " .. parent.nodeType)
	self.parentLabel:show()
end

---@param node DiagramNode
function InfoPanelHead:setChildren(node)
	local children = node:getChildrenNodes()

	if #children == 0 then
		self.childrenLabel:hide()
		return
	end

	if #children == 1 then
		self.childrenLabel:setText("Child: " .. children[1].nodeType)
	else
		self.childrenLabel:setText("Children: " .. #children)
	end

	self.childrenLabel:show()
end

function InfoPanelHead:new()
	local fontS = love.graphics.newFont(self.font, 16)
	local fontL = love.graphics.newFont(self.font, 24)

	self.picture = self:createChild "InfoPanelPicture" {
		w = 80,
		h = 80,
	}

	local text_container = self:createChild "Container" {
		w = "fill",
		h = "hug",
		growth = "vertical",
		horizontal = "left",
		vertical = "top",
		gap = 2,
		padding = {0, 3, 0, 0},
	}

	self.nameLabel = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = fontL,
		textColor = COLORS.NODE_TEXT,
		text = "Node Type"
	}

	self.parentLabel = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = fontS,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "Parent: "
	}
	self.parentLabel:hide()

	self.childrenLabel = text_container:createChild "Label" {
		w = "fill",
		h = "hug",
		font = fontS,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "Children: "
	}
	self.childrenLabel:hide()
end

return InfoPanelHead