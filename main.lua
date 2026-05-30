io.stdout:setvbuf("no")

local listener

local changed

function love.load()
	local gui = require("libs.stellargui"):hook()
	local TCPListener = require("classes.TCPListener")

	gui.loadExternalObjects("libs/stellargui/classes")

	local mastercanvas = require("ui.scenes.master")
	gui.storeCanvas("master", mastercanvas)
	gui.setCanvas("master")

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