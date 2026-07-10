-- DiagramNodeNavigation

---@class DiagramNodeNavigation : Button
---@field compact boolean
---@field style "Up"|"Down"|"Left"|"Right"
---@field pointer DiagramNode
local DiagramNodeNavigation = {
	name = "DiagramNodeNavigation",
	extends = "Button",
	rules = {
		{{"compact"}, "compact"},
		{{"style"}, "style"},
		{{"pointer"}, "pointer"},
	},
	default = {
		w = "hug",
		h = "hug",
		growth = "horizontal",
		gap = 5,
		padding = {8, 5},
		r = 16,
		color = COLORS.NODE_NAVIGATION,
		static = true,

		compact = false,
		style = "Up",
	},

	defaultCursor = "hand"
}

function DiagramNodeNavigation:action()
	self.parent.parent:renderNodeInfo(self.pointer, true)

	local tx, ty = self.parent:getTranslation()
	local ntx, nty = self.pointer:getTranslation()

	self.parent.parent:moveRoot(tx - ntx, ty - nty)
end

function DiagramNodeNavigation:createLabel()
	if self.compact then
		return
	end

	self:createChild "Container" {
		padding = {5, 2},
		color = COLORS.NODE_FILL,
		additionalColor = self.pointer.palette:getColorByIndex(3),
		borderSize = 2,
		r = 5
	} : createChild "Label" {
		text = self.pointer.nodeType,
		font = self.pointer.desc_font,
		textColor = COLORS.NODE_TEXT
	}
end

function DiagramNodeNavigation:createArrow()
	local arrow_color

	if self.compact then
		arrow_color = self.pointer.palette:getColorByIndex(3)
	else
		arrow_color = COLORS.NODE_NAVIGATION_ARROW
	end

	self:createChild "Icon" {
		w = 22,
		h = 22,
		style = "Arrow" .. self.style,
		color = arrow_color
	}
end

function DiagramNodeNavigation:new()
	assert(self.pointer, "Parameter \"pointer\" required for DiagramNodeNavigation object")

	self.border_flag = false
	self.objects = {}

	if self.compact then
		self.layout.padding = {5, 5, 5, 5}
	end

	if self.style == "Left" then
		self:createLabel()
		self:createArrow()

		return
	end

	self:createArrow()
	self:createLabel()
end

return DiagramNodeNavigation