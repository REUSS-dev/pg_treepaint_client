io.stdout:setvbuf("no")

local listener

local changed

function love.load()
	local gui = require("libs.stellargui"):hook()

	gui.loadExternalObjects("libs/stellargui/classes")
	gui.loadExternalObjects("ui/objects")

	local mastercanvas = require("ui.scenes.master")
	gui.storeCanvas("master", mastercanvas)
	gui.setCanvas("master")
end

function love.update(dt)
end

function love.draw()
end