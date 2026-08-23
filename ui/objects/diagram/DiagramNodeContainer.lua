-- horizontal

-- class

---@class DiagramNodeContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field parent DiagramNode
---@field font {M: love.Font, S: love.Font}
local DiagramNodeContainer = {
	name = "DiagramNodeContainer",
	extends = "CompositeObject",
	rules = {
	},
	default = {
		growth = "vertical",
		gap = 2,
		horizontal = "left",
		w = "fill",
		h = "hug",

		textColor = COLORS.NODE_TEXT,
		font = {M = "default 18", S = "default 16"}
	}
}

---@param str string
---@param vars table|any?
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addTextParametrized(str, vars, greyed)
	if not vars then
		return self
	end

	if type(vars) == "table" then
		return self:addText(str, greyed, vars)
	end

	return self:addText(str, greyed, {vars})
end

---@param prefix string
---@param value (string|integer)?
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
function DiagramNodeContainer:addText(text, greyed, vars)
	self:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = text,
		with = vars,
		textColor = greyed and self.text_color_desc or self.text_color,
	}

	return self
end

---@param str string
---@param vars table|any?
---@param greyed boolean?
---@return DiagramNodeContainer
function DiagramNodeContainer:addDescParametrized(str, vars, greyed)
	if not vars then
		return self
	end

	if type(vars) == "table" then
		return self:addDesc(str, greyed, vars)
	end

	return self:addDesc(str, greyed, {vars})
end

---@param prefix string
---@param value (string|integer)?
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
function DiagramNodeContainer:addDesc(text, greyed, vars)
	self:createChild "Label" {
		w = "fill",
		font = self.font.S,
		horizontal = "left",
		text = text,
		with = vars,
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