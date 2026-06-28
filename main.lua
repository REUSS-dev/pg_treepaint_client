io.stdout:setvbuf("no")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
	print("debugger enabled")
end

local gui = require("libs.stellargui")

function love.load()
	gui.loadExternalObjects()
	gui.loadExternalObjects("ui/objects")

	local mastercanvas = require("ui.scenes.master")
	gui.storeCanvas("master", mastercanvas)
	gui.setCanvas("master")
end

function love.update(dt)
end

function love.draw()
end