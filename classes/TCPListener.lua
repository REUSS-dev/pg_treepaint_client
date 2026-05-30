-- classes/TCPListener.lua

-- consts

local CHANNEL_PREFIX = "TCPListener_"

---@class TCPListener
---@field thread love.Thread
---@field channel love.Channel
---@field ip string
---@field port integer
---@field channel_name string
local TCPListener = {}
TCPListener.__index = TCPListener

function TCPListener:start()
	if self.channel then
		return
	end

	self.channel = love.thread.getChannel(self.channel_name)

	self.thread:start(self.ip, self.port, self.channel_name)

	print("Started listener on " .. self.ip .. ":" .. self.port)

	return self
end

function TCPListener:pop()
	return self.channel:pop()
end

function TCPListener:new(ip, port)
	local new_listener = {
		ip = assert(type(ip) == "string" and ip, "IP (string) is required to create new TCPListener object, received " .. type(ip)),
		port = assert(port and tonumber(port), "Port (number) is required to create new TCPListener object, received " .. type(ip)),
		channel_name = CHANNEL_PREFIX .. ip .. ":" .. port
	}

	setmetatable(new_listener, TCPListener)

	local socket_thread = love.thread.newThread("scripts/thread_socket.lua")
	new_listener.thread = socket_thread

	return new_listener
end

setmetatable(TCPListener, {__call = TCPListener.new})

return TCPListener