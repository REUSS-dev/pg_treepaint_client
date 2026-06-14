-- PasteApplet

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
local PasteApplet = {
	name = "PasteApplet",
	extends = "Button",
	default = {
		w = 140, h = "fill",
		colors = {
			main = {100/255, 100/255, 0, 1},
			border = {200/255, 200/255, 100/255, 1},
			text = {1, 1, 1, 1}
		},

		text = "Plot\nfrom clipboard",
		r = 5,
		bsize = 3
	}
}

function PasteApplet:action()
	if not self.diagram then
		print("Cannot plot, diagram is not assigned to PasteApplet object")
		return
	end

	local clipboard = love.system.getClipboardText()

	if not clipboard then
		print("Cannot plot, clipboard does not contain text")
		return
	end

	if clipboard:sub(1, 1) ~= "[" then ---@todo multiple explain types
		print("Cannot plot, clipboard does not contain valid plan data")
		return
	end

	clipboard = clipboard:gsub("([^+\r])\r?\n", "%1")
	clipboard = clipboard:gsub("%+\r?\n", " ")
	clipboard = fix_data(clipboard)

	self.diagram:plot(clipboard)
end

function PasteApplet:registerDiagramObject(obj)
	self.diagram = obj
end

return PasteApplet