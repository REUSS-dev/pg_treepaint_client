-- TCP Client
CLIENT_IP = "0.0.0.0"               -- TCP Client listenning IP address
CLIENT_PORT = 4523                  -- TCP Client listening port
CLIENT_AUTOSTART = false            -- Start TCP Client on launch

-- Program locale. Locales are stored in directory "locale" and are ISO 639-1 + (optionally) ISO 3166-1 language codes like en_US or ru_RU. Can also be just "en" or "ru".
-- Supported variants: en_US, ru_RU
LOCALE = "en"

-- Program color scheme. Schemes are described and defined in themes.lua
-- Supported variants: dark, light
UI_THEME = "dark"

-- Dimensions of plan minimap. In pixels
MINIMAP_DIMENSIONS = {300, 200}

-- Size of PostgreSQL buffer, used for calculations default is 8192 bytes
BUFFER_SIZE = 8192

function love.conf(t)
    t.version = "11.5"

	t.window.title = "Treepaint"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 854
    t.window.minheight = 480
	t.window.icon = "icon.png"
	t.window.msaa = 1


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

--#region Handle Windows DPI settings
if love._os == "Windows" then
  local ffi = require "ffi"
  ffi.cdef[[ bool SetProcessDPIAware(); ]]
  ffi.C.SetProcessDPIAware();
end
--#endregion

require("themes")