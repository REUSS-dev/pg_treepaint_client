io.stdout:setvbuf("no")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
	print("debugger enabled")
end

IDENTITY = {
	extension_url = "https://github.com/REUSS-dev/pg_treepaint"
}

local gui = require("libs.stellargui")

function love.load()
	gui.loadExternalObjects()
	gui.loadExternalObjects("ui/objects")

	gui.setLocale(LOCALE)

	local mastercanvas = require("ui.scenes.master")
	gui.storeCanvas("master", mastercanvas)
	gui.setCanvas("master")
end

function love.update(dt)
end

function love.draw()
end