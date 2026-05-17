local bind_ip, bind_port, channel = ...

require("love.timer")
local socket = require("socket")

local server = socket.tcp()
server:bind(bind_ip, bind_port)
server:listen()

local output = love.thread.getChannel(channel)

local client

local function send_client_connect(client_address)
	output:push{
		type = "socket_connect",
		data = client_address
	}
end

local function send_client_disconnect(client_address)
	output:push{
		type = "socket_disconnect",
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
	end

	client:settimeout(100)

	local ip, port = client:getpeername()
	send_client_connect(ip .. ":" .. port)
end

-- init

wait_client()

while true do
	local msg, err = client:receive("*a")

	if msg then
		send_data(msg)
	else
		local ip, port = client:getpeername()
		send_client_disconnect(ip .. ":" .. port)

		wait_client()
	end
end