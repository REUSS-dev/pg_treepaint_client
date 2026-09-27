local bind_ip, bind_port, channel, control_channel = ...

require("love.timer")
local socket = require("socket")

local server = socket.tcp()
server:settimeout(0.05)
server:bind(bind_ip, bind_port)
server:listen()

local output = love.thread.getChannel(channel)
local control = love.thread.getChannel(control_channel)

local client

local function send_client_connect(client_address)
	output:push{
		type = "connect",
		data = client_address
	}
end

local function send_client_disconnect(client_address)
	output:push{
		type = "disconnect",
		data = client_address
	}
end

local function send_data(data)
	output:push{
		type = "data",
		data = data
	}
end

local function wait_client()
	if client then
		client:shutdown()
		client = nil
	end

	while not client do
		client = server:accept()

		local msg = control:pop()

		if msg then
			if msg == "stop" then
				server:close()
				return true
			end
		end
	end

	client:settimeout(0.1)

	local ip, port = client:getpeername()
	send_client_connect(ip .. ":" .. port)
end

-- init

if not wait_client() then
	while true do
		local msg, _ = client:receive("*a")

		if msg then
			send_data(msg)
		else
			local ip, port = client:getpeername()
			send_client_disconnect(ip .. ":" .. port)

			if wait_client() then break end
		end
	end
end