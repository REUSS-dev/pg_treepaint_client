-- tcp
local tcp = {}

local gui = require("libs.stellargui")
local composite = require("classes.CompositeObject")

-- documentation



-- config

tcp.name = "TCPApplet"
tcp.aliases = {}
tcp.rules = {
    {"layout", {w = 150, h = "fill"}},
	{"palette", {text_color = {1, 1, 1, 1}}},

	{{"tcp", "tcp_listener", "tcp_client"}, "tcp", nil},
	{{"font"}, "font", love.graphics.getFont()},

    {{"r", "radius", "rounding", "round"}, "r", nil},
	{{"bsize", "border_size", "borderSize"}, "bsize", 3},
}

-- consts

local COLOR_ACTIVE = {0, 100/255, 0, 1}
local BORDER_ACTIVE = {100/255, 200/255, 100/255, 1}

local COLOR_INACTIVE = {100/255, 0, 0, 1}
local BORDER_INACTIVE = {200/255, 100/255, 100/255, 1}

-- vars



-- init



-- fnc



-- classes

---@class TCPApplet : CompositeObject
---@field r number Radius of round corner
---@field font love.Font
---@field status TCPListenerStatus
---@field tcp TCPListener
---@field label Label
local TCPApplet = {}
local TCPApplet_meta = {__index = TCPApplet}
setmetatable(TCPApplet, {__index = composite.class}) -- Set parenthesis

function TCPApplet:tick(dt)
	composite.class.tick(self, dt)

	local current_status = self.tcp:getStatus()

	if current_status ~= self.status then
		self.status = current_status

		if current_status == self.tcp.Status.ACTIVE then
			self.palette:setColor(1, COLOR_ACTIVE)
			self.palette:setColor(3, BORDER_ACTIVE)

			self.label:setText("TCP Active\n" .. self.tcp:getBindAddress())
		elseif current_status == self.tcp.Status.INACTIVE then
			self.palette:setColor(1, COLOR_INACTIVE)
			self.palette:setColor(3, BORDER_INACTIVE)

			self.label:setText("TCP Inactive")
		end
	end
end

-- image fnc

function tcp.new(prototype)
    local obj = composite.new(prototype)
    setmetatable(obj, TCPApplet_meta)
	---@cast obj TCPApplet
	
	if not obj.tcp then
		error("TCPApplet must be provided with tcp listener")
	end

	obj.fill_flag, obj.border_flag = true, true

	obj.label = gui.Label{
		font = obj.font,
		horizontal = "center"
	}
	obj:add(obj.label)

    return obj
end

return tcp