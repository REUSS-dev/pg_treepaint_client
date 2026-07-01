CLIENT_IP = "0.0.0.0"
CLIENT_PORT = 4523

UI_THEME = "dark"
require("themes")

function love.conf(t)
	t.window.title = "Treepaint"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 854
    t.window.minheight = 480
	t.window.icon = "icon.png"
	t.window.msaa = 4


	t.modules.audio = false
    t.modules.data = false
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end