-- PasteApplet

-- classes

---@class PasteApplet : Button
---@field r number Radius of round corner
---@field label Label
---@field diagram DiagramArea?
local PasteApplet = {
	name = "PasteApplet",
	extends = "Button",
	default = {
		w = 140, h = "fill",
		colors = {
			main = COLORS.PASTE_FILL,
			border = COLORS.PASTE_BORDER,
			text = COLORS.PASTE_TEXT
		},

		text = "header.paste.button",
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

	clipboard = clipboard:gsub("%+\r?\n", " ")

	self.diagram:plot(clipboard)
end

---@param obj DiagramArea
function PasteApplet:registerDiagramObject(obj)
	self.diagram = obj
end

return PasteApplet