-- tcp
local tcp = {}

local button = require("classes.objects.Button")

-- documentation



-- config

tcp.name = "PasteApplet"
tcp.aliases = {}
tcp.rules = {
    {"layout", {w = 140, h = "fill"}},
	{"palette", {color = {100/255, 100/255, 0, 1}, additionalColor = {200/255, 200/255, 100/255, 1}, text_color = {1, 1, 1, 1}}},

	{{"font"}, "font", love.graphics.getFont()},
	{{"text", "label"}, "text", "Plot\nfrom clipboard"},
    {{"r", "radius", "rounding", "round"}, "r", 5},
	{{"bsize", "border_size", "borderSize"}, "bsize", 3},
}

-- consts



-- vars



-- init



-- fnc

local function fix_data(data)
	if data:sub(-1, -1) == "]" then
		return data
	end

	return data .. "}" .. "]"
end

-- classes

---@class PasteApplet : Button
---@field r number Radius of round corner
---@field font love.Font
---@field label Label
---@field diagram DiagramArea?
local PasteApplet = {}
local PasteApplet_meta = {__index = PasteApplet}
setmetatable(PasteApplet, {__index = button.class}) -- Set parenthesis

function PasteApplet:action()
	if not self.diagram then
		return
	end

	local clipboard = love.system.getClipboardText()

	if not clipboard then
		return
	end

	if clipboard:sub(1, 1) ~= "[" then ---@todo multiple explain types
		return
	end

	clipboard = clipboard:gsub("%+\r?\n", "\n")
	clipboard = fix_data(clipboard)

	self.diagram:plot(clipboard)
end

function PasteApplet:registerDiagramObject(obj)
	self.diagram = obj
end

-- image fnc

function tcp.new(prototype)
    local obj = button.new(prototype)
    setmetatable(obj, PasteApplet_meta)
	---@cast obj PasteApplet

    return obj
end

return tcp