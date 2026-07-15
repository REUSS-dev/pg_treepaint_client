-- MinimapApplet

---@class MinimapApplet : CompositeObject
---@field zoomButtons CompositeObject
---@field zoomCurrent integer
---@field zoomDefault integer
---@field zoomOptions number[]
---@field map DiagramMinimap
---@field root DiagramNode
local MinimapApplet = {
	name = "MinimapApplet",
	extends = "CompositeObject",
	rules = {
		{{1, "node", "root"}, "root"},
	},
	default = {
		growth = "horizontal",
		vertical = "top",
		static = true,

		color = COLORS.NODE_FILL,
		additionalColor = COLORS.NODE_BORDER,
		textColor = COLORS.NODE_TEXT,
		font = "default 18",
	},

	minimapHideColor = COLORS.NODE_HOVER,

	zoomOptions = {0.05, 0.0625, 0.075, 0.0875, 0.1, 0.125, 0.15},
	zoomDefault = 3
}

function MinimapApplet:toggleVisibility()
	if self.map:isDrawn() then
		self.map:hide()
		self.zoomButtons:hide()
	else
		self.map:show()
		self.zoomButtons:show()
	end
end

function MinimapApplet:refreshMinimap()
	self.map:refreshMinimap()
end

function MinimapApplet:zoomDown()
	if self.zoomCurrent == 1 then
		return
	end

	self.zoomCurrent = self.zoomCurrent - 1

	local result = self.map:setScale(self.zoomOptions[self.zoomCurrent])

	if not result then
		self.zoomCurrent = self.zoomCurrent + 1
	end
end

function MinimapApplet:zoomUp()
	if self.zoomCurrent == #self.zoomOptions then
		return
	end

	self.zoomCurrent = self.zoomCurrent + 1

	local result = self.map:setScale(self.zoomOptions[self.zoomCurrent])

	if not result then
		self.zoomCurrent = self.zoomCurrent - 1
	end
end

function MinimapApplet:new()
	self.fill_flag = false
	self.border_flag = false

	self.zoomCurrent = self.zoomDefault

	local buttons_container = self:createChild "Container" {
		growth = "vertical",
		gap = 20
	}

	buttons_container:createChild "Button" {
		text = "#",
		font = self.font,
		w = 30,
		h = 30,
		r = 5,
		bsize = 1,

		color = self.minimapHideColor,
		additionalColor = self.palette.border,
		textColor = self.palette.text,

		action = function ()
			self:toggleVisibility()
		end
	}

	local zoomButtons = buttons_container:createChild "Container" {
		growth = "vertical",
		gap = 10,
	}

	zoomButtons:createChild "Button" {
		text = "+",
		font = self.font,
		w = 30,
		h = 30,
		r = 5,
		bsize = 1,

		color = self.palette.main,
		additionalColor = self.palette.border,
		textColor = self.palette.text,

		action = function ()
			self:zoomUp()
		end
	}

	zoomButtons:createChild "Button" {
		text = "-",
		font = self.font,
		w = 30,
		h = 30,
		r = 5,
		bsize = 1,

		color = self.palette.main,
		additionalColor = self.palette.border,
		textColor = self.palette.text,

		action = function ()
			self:zoomDown()
		end
	}

	self.zoomButtons = zoomButtons

	self.map = self:createChild "DiagramMinimap" {
		root = self.root,
		scale = self.zoomOptions[self.zoomCurrent]
	}
end

return MinimapApplet