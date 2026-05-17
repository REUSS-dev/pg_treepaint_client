io.stdout:setvbuf("no")

local channel

function love.load()
	local socket_thread = love.thread.newThread("scripts/thread_socket.lua")
	socket_thread:start(CLIENT_IP, CLIENT_PORT, SOCKET_CHANNEL)

	channel = love.thread.getChannel(SOCKET_CHANNEL)
end

function love.update(dt)
	local message = channel:pop()

	if message then
		print(message.type, message.data)
	end
end

function love.draw()
end