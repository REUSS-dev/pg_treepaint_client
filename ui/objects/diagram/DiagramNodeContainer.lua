-- horizontal

-- class

---@class DiagramNodeContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field parent DiagramNode
---@field font love.Font
---@field desc_font love.Font
local DiagramNodeContainer = {
	name = "DiagramNodeContainer",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"},
		{{"desc_font"}, "desc_font"}
	},
	default = {
		growth = "vertical",
		gap = 2,
		horizontal = "left",
		w = "fill",
		h = "hug",

		textColor = COLORS.NODE_TEXT
	}
}

---@param prefix string
---@param value string?
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addTextProtected(prefix, value, greyed)
	if not value then
		return self
	end

	return self:addText(prefix .. value, greyed)
end

---@param text string
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addText(text, greyed)
	self:createChild "Label" {
		w = "fill",
		font = self.font,
		horizontal = "left",
		text = text,
		textColor = greyed and self.text_color_desc or self.text_color,
	}

	return self
end

---@param prefix string
---@param value string?
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addDescProtected(prefix, value, greyed)
	if not value then
		return self
	end

	return self:addDesc(prefix .. value, greyed)
end

---@param text string
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addDesc(text, greyed)
	self:createChild "Label" {
		w = "fill",
		font = self.desc_font,
		horizontal = "left",
		text = text,
		textColor = greyed and self.text_color_desc or self.text_color,
	}

	return self
end

-- horizontal fnc

function DiagramNodeContainer:new()
	self.text_color = self.palette:getColorByIndex(2)

	if not self.palette:getColorByIndex(4) then
		self.palette:setColor(4, COLORS.NODE_TEXT_DESC)
	end
	self.text_color_desc = self.palette:getColorByIndex(4)
end

return DiagramNodeContainer