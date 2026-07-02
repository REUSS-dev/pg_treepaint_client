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
	self.parentLabel:hide()
	self.childrenLabel:hide()

	if node.parent.name == "DiagramHorizontalContainer" then
		if node.parent.parent.name == "DiagramVerticalContainer" then
			self:setParent(node.parent.parent.objects[1].nodeType)
		end
	elseif node.parent.name == "DiagramVerticalContainer" then
		if node.parent.objects[2] == node then
			self:setParent(node.parent.objects[1].nodeType)
		elseif node.parent.objects[1] == node then
			if node.parent.parent.name == "DiagramHorizontalContainer" then
				if node.parent.parent.parent.name == "DiagramVerticalContainer" then
					self:setParent(node.parent.parent.parent.objects[1].nodeType)
				end
			elseif node.parent.parent.name == "DiagramVerticalContainer" then
				self:setParent(node.parent.parent.objects[1].nodeType)
			end

			if node.parent.objects[2].name == "DiagramHorizontalContainer" then
				self:setChildren(node.parent.objects[2].objects)
			elseif node.parent.objects[2].name == "DiagramVerticalContainer" then
				self:setChild(node.parent.objects[2].objects[1].nodeType)
			else
				self:setChild(node.parent.objects[2].nodeType)
			end
		end
	end
end

function InfoPanelHead:setParent(parent_name)
	self.parentLabel:setText("Parent: " .. parent_name)
	self.parentLabel:show()
end

function InfoPanelHead:setChild(child_name)
	self.childrenLabel:setText("Child: " .. child_name)
	self.childrenLabel:show()
end

function InfoPanelHead:setChildren(children)
	self.childrenLabel:setText("Children: " .. #children)
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