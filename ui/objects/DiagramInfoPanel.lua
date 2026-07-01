-- DiagramInfoPanel

local angelic = require("libs.angeliclove")

-- config

local CACHE_SIZE = 5

---@class DiagramInfoPanel : CompositeObject
---@field font string
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field picture Label
---@field titleLabelContainer CompositeObject
---@field cacheStorage table<DiagramNode, CompositeObject[]>
local DiagramInfoPanel = {
	name = "DiagramInfoPanel",
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
function DiagramInfoPanel:displayNode(node)
	if not self.cacheStorage[node] then
		self:createContents(node)
	end

	self:setNodeInfo(node)
	--self.contentsContainer.objects = self.cacheStorage[node]
	self.contentsContainer:relayout()

	self:show()
end

---@param node DiagramNode
function DiagramInfoPanel:setNodeInfo(node)
	self.picture.palette:setColor(2, {node.palette.border[1], node.palette.border[2], node.palette.border[3], 1})
	self.picture:setText(node.nodeType and string.sub(node.nodeType, 1, 1) or "A")

	self.titleLabelContainer.objects[1]:setText(node.nodeType)

	self.titleLabelContainer.objects[2]:hide()
	self.titleLabelContainer.objects[3]:hide()

	if node.parent.name == "DiagramHorizontalContainer" then
		if node.parent.parent.name == "DiagramVerticalContainer" then
			self.titleLabelContainer.objects[2]:setText("Parent: " .. node.parent.parent.objects[1].nodeType)
			self.titleLabelContainer.objects[2]:show()
		end
	elseif node.parent.name == "DiagramVerticalContainer" then
		if node.parent.objects[2] == node then
			self.titleLabelContainer.objects[2]:setText("Parent: " .. node.parent.objects[1].nodeType)
			self.titleLabelContainer.objects[2]:show()
		elseif node.parent.objects[1] == node then
			if node.parent.parent.name == "DiagramHorizontalContainer" then
				if node.parent.parent.parent.name == "DiagramVerticalContainer" then
					self.titleLabelContainer.objects[2]:setText("Parent: " .. node.parent.parent.parent.objects[1].nodeType)
					self.titleLabelContainer.objects[2]:show()
				end
			elseif node.parent.parent.name == "DiagramVerticalContainer" then
				self.titleLabelContainer.objects[2]:setText("Parent: " .. node.parent.parent.objects[1].nodeType)
				self.titleLabelContainer.objects[2]:show()
			end

			if node.parent.objects[2].name == "DiagramHorizontalContainer" then
				self.titleLabelContainer.objects[3]:setText("Children: " .. #node.parent.objects[2].objects)
				self.titleLabelContainer.objects[3]:show()
			elseif node.parent.objects[2].name == "DiagramVerticalContainer" then
				self.titleLabelContainer.objects[3]:setText("Child: " .. node.parent.objects[2].objects[1].nodeType)
				self.titleLabelContainer.objects[3]:show()
			else
				self.titleLabelContainer.objects[3]:setText("Child: " .. node.parent.objects[2].nodeType)
				self.titleLabelContainer.objects[3]:show()
			end
		end
	end
end

---@param node DiagramNode
function DiagramInfoPanel:createContents(node)
	
end

function DiagramInfoPanel:new()
	self.angelicfont = angelic.new("automata", 60):getFont()
	self.fontS = love.graphics.newFont(self.font, 16)
	self.fontM = love.graphics.newFont(self.font, 20)
	self.fontL = love.graphics.newFont(self.font, 24)

	self.cacheStorage = {}

	-- Title container
	self.titleContainer = self:createChild "Container" { gap = 10, horizontal = "left", vertical = "top", w = "fill", h = "hug", growth = "horizontal" }

	self.picture = self.titleContainer:createChild "Container" {
		w = 80,
		h = 80,
		padding = 10,
		r = 10,
		color = COLORS.INFO_PANEL_ELEMENT
	} : createChild "Label" {
		text = "A",
		font = self.angelicfont,
		align = "center"
	}

	self.titleLabelContainer = self.titleContainer:createChild "Container" {
		w = "fill",
		h = "hug",
		growth = "vertical",
		vertical = "top",
		gap = 2,
		padding = {0, 3, 0, 0},
	}

	self.titleLabelContainer:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.fontL,
		textColor = COLORS.NODE_TEXT,
		text = "Node Type"
	}

	self.titleLabelContainer:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.fontS,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "Parent: "
	}

	self.titleLabelContainer:createChild "Label" {
		w = "fill",
		h = "hug",
		font = self.fontS,
		textColor = COLORS.NODE_TEXT_DESC,
		text = "Children: "
	}


	self.contentsContainer = self:createChild "Container" { gap = 5, horizontal = "left", w = "fill" }
	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self:hide()
end

return DiagramInfoPanel