io.stdout:setvbuf("no")

local listener

function love.load()
	local TCPListener = require("classes.TCPListener")

	listener = TCPListener(CLIENT_IP, CLIENT_PORT):start()
end

function love.update(dt)
	local message = listener:pop()

	if message then
		print(message.type, message.data)
	end
end

function love.draw()
end