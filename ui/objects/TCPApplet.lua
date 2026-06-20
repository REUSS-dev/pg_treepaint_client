-- tcp

-- consts

local COLOR_ACTIVE = COLORS.TCP_ACTIVE
local BORDER_ACTIVE = COLORS.TCP_ACTIVE_BORDER

local COLOR_INACTIVE = COLORS.TCP_INACTIVE
local BORDER_INACTIVE = COLORS.TCP_INACTIVE_BORDER

-- fnc

local function fix_data(data) ---@todo multiple explain types
	return data .. "}" .. "]"
end

-- classes

---@class TCPApplet : CompositeObject
---@field CompositeObject CompositeObject
---@field r number Radius of round corner
---@field font love.Font
---@field status TCPListenerStatus
---@field tcp TCPListener
---@field label Label
---@field diagram DiagramArea?
local TCPApplet = {
	name = "TCPApplet",
	extends = "CompositeObject",
	rules = {
		{{"tcp", "tcp_listener", "tcp_client"}, "tcp"},
		{{"font"}, "font"},
	},
	default = {
		w = 150, h = "fill",
		text_color = {1, 1, 1, 1},
		font = love.graphics.getFont()
	}
}

function TCPApplet:tick(dt)
	self.CompositeObject.tick(self, dt)

	local current_status = self.tcp:getStatus()

	if current_status == self.tcp.Status.ACTIVE then
		local msg = self.tcp:pop()

		if msg then
			if msg.type == "data" then
				if self.diagram then
					self.diagram:plot(fix_data(msg.data))
				end
			end
		end
	end

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

function TCPApplet:registerDiagramObject(obj)
	self.diagram = obj
end

function TCPApplet:new()
	if not self.tcp then
		error("TCPApplet must be provided with tcp listener")
	end

	self.fill_flag, self.border_flag = true, true

	self.label = self:createChild "Label" {
		font = self.font,
		horizontal = "center"
	}
end

return TCPApplet