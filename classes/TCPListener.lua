-- classes/TCPListener.lua

-- docs

---@alias TCPMessageType "connect"|"data"|"disconnect"
---@alias TCPMessage {type: TCPMessageType, data: string}

-- consts

---@enum TCPListenerStatus
local Status = {
	ACTIVE = 1,
	INACTIVE = 2
}

local CHANNEL_PREFIX = "TCPListener_"

-- class

---@class TCPListener
---@field thread love.Thread
---@field status TCPListenerStatus
---@field channel love.Channel
---@field controlChannel love.Channel
---@field ip string
---@field port integer
---@field channel_name string
---@field control_channel_name string
local TCPListener = {}
TCPListener.__index = TCPListener

function TCPListener:start()
	if self.status == Status.ACTIVE then
		return
	end

	self.channel = self.channel or love.thread.getChannel(self.channel_name)
	self.controlChannel = self.controlChannel or love.thread.getChannel(self.control_channel_name)

	self.thread:start(self.ip, self.port, self.channel_name, self.control_channel_name)

	print("Started listener on " .. self.ip .. ":" .. self.port)

	self.status = Status.ACTIVE

	return self
end

function TCPListener:stop()
	if self.status == Status.INACTIVE then
		return
	end

	self.controlChannel:push("stop")

	print("Stopped listener on " .. self.ip .. ":" .. self.port)

	self.status = Status.INACTIVE

	return self
end

function TCPListener:toggle()
	if self.status == Status.ACTIVE then
		self:stop()
	else
		self:start()
	end
end

---Return current listener status
---@return TCPListenerStatus
function TCPListener:getStatus()
	return self.status
end

function TCPListener:getBindAddress()
	return self.ip .. ':' .. self.port
end

---Pops TCP thread channel
---@return TCPMessage?
function TCPListener:pop()
	return self.channel:pop()
end

function TCPListener:new(ip, port)
	local new_listener = {
		ip = assert(type(ip) == "string" and ip, "IP (string) is required to create new TCPListener object, received " .. type(ip)),
		port = assert(port and tonumber(port), "Port (number) is required to create new TCPListener object, received " .. type(ip)),
		channel_name = CHANNEL_PREFIX .. ip .. ":" .. port,
		control_channel_name = CHANNEL_PREFIX .. ip .. ":" .. port .. "_CONTROL",

		status = Status.INACTIVE
	}

	setmetatable(new_listener, TCPListener)

	local socket_thread = love.thread.newThread("scripts/thread_socket.lua")
	new_listener.thread = socket_thread

	return new_listener
end

setmetatable(TCPListener, {__call = TCPListener.new})

TCPListener.Status = Status

return TCPListener