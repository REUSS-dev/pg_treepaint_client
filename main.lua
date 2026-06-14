io.stdout:setvbuf("no")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
	print("debugger enabled")
end

function love.load()
	local gui = require("libs.stellargui"):hook()

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