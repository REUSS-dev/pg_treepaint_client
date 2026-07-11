-- InfoPanelBuffers

local EPS = 0.0000000000001
local BUFFER_SIZE = BUFFER_SIZE / 1024

---@enum ViewStates
local ViewStates = {
	PAGE = "123",
	PERCENT = "%",
	BYTES = "KB"
}

local InformationUnits = {"kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "RB", "QB"}

local DEFAULT_VIEW_STATE = ViewStates.PAGE

---@class InfoPanelBuffers : CompositeObject
---@field CompositeObject CompositeObject
---@field buffers BufferTable
---@field font string
---@field fontS love.Font
---@field shared_row {objects: Label[]}?
---@field local_row {objects: Label[]}?
---@field temp_row {objects: Label[]}?
---@field total_row {objects: Label[]}?
---@field populatedView ViewStates?
local InfoPanelBuffers = {
	name = "InfoPanelBuffers",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"},
		{{"buffers"}, "buffers"},
	},
	default = {
		w = "fill",
		h = "hug",
		growth = "vertical",
		gap = 0,
		horizontal = "left",
		vertical = "top",
		r = 15,
		padding = {10, 2},
		color = COLORS.INFO_BUFFERS,
	},

	currentView = {DEFAULT_VIEW_STATE}
}

function InfoPanelBuffers:paint(...)
	self:resolveView()
	self.CompositeObject.paint(self)
end

function InfoPanelBuffers:toggleView()
	local current_view = self.currentView[1]

	if current_view == ViewStates.PAGE then
		self.currentView[1] = ViewStates.PERCENT
	elseif current_view == ViewStates.PERCENT then
		self.currentView[1] = ViewStates.BYTES
	elseif current_view == ViewStates.BYTES then
		self.currentView[1] = ViewStates.PAGE
	end

	self:redraw()
end

function InfoPanelBuffers:resolveView()
	if not self.header then
		return
	end

	local current_view = self.currentView[1]

	if current_view == self.populatedView then
		return
	end

	if current_view == ViewStates.PAGE then
		self:populatePage()
		self.header.objects[1].objects[1].objects[1]:setText(ViewStates.PAGE)
	elseif current_view == ViewStates.PERCENT then
		self:populatePercent()
		self.header.objects[1].objects[1].objects[1]:setText(ViewStates.PERCENT)
	elseif current_view == ViewStates.BYTES then
		self:populateBytes()
		self.header.objects[1].objects[1].objects[1]:setText(ViewStates.BYTES)
	end

	self.populatedView = current_view
end

function InfoPanelBuffers:populatePage()
	self:populatePageRow(self.shared_row, self.buffers.Shared)
	self:populatePageRow(self.local_row, self.buffers.Local)
	self:populatePageRow(self.temp_row, self.buffers.Temp)
	self:populatePageRow(self.total_row, self.buffers.Total)
end

function InfoPanelBuffers:populatePageRow(row, buffer_values)
	if row then
		row.objects[2]:setText(buffer_values.hit ~= 0 and tostring(buffer_values.hit) or "")
		row.objects[3]:setText(buffer_values.read ~= 0 and tostring(buffer_values.read) or "")
		row.objects[4]:setText(buffer_values.dirtied ~= 0 and tostring(buffer_values.dirtied) or "")
		row.objects[5]:setText(buffer_values.written ~= 0 and tostring(buffer_values.written) or "")
	end
end

function InfoPanelBuffers:populatePercent()
	self:populatePercentRow(self.shared_row, self.buffers.Shared)
	self:populatePercentRow(self.local_row, self.buffers.Local)
	self:populatePercentRow(self.temp_row, self.buffers.Temp)
	self:populatePercentRow(self.total_row, self.buffers.Total)
end

function InfoPanelBuffers:populatePercentRow(row, buffer_values)
	if row then
		row.objects[2]:setText(self:getFitPercent(buffer_values.hit / buffer_values.total, row.objects[2].w))
		row.objects[3]:setText(self:getFitPercent(buffer_values.read / buffer_values.total, row.objects[3].w))
		row.objects[4]:setText(self:getFitPercent(buffer_values.dirtied / buffer_values.total, row.objects[4].w))
		row.objects[5]:setText(self:getFitPercent(buffer_values.written / buffer_values.total, row.objects[5].w))
	end
end

---@param value number
---@param width integer
---@return string
function InfoPanelBuffers:getFitPercent(value, width)
	if value < EPS then
		return ""
	end

	value = value * 100

	return self:fitNumber(value, "%", width) or "?"
end

function InfoPanelBuffers:populateBytes()
	self:populateBytesRow(self.shared_row, self.buffers.Shared)
	self:populateBytesRow(self.local_row, self.buffers.Local)
	self:populateBytesRow(self.temp_row, self.buffers.Temp)
	self:populateBytesRow(self.total_row, self.buffers.Total)
end

function InfoPanelBuffers:populateBytesRow(row, buffer_values)
	if row then
		row.objects[2]:setText(self:getFitBytes(buffer_values.hit, row.objects[2].w))
		row.objects[3]:setText(self:getFitBytes(buffer_values.read, row.objects[3].w))
		row.objects[4]:setText(self:getFitBytes(buffer_values.dirtied, row.objects[4].w))
		row.objects[5]:setText(self:getFitBytes(buffer_values.written, row.objects[5].w))
	end
end

---@param bufer_count integer
---@param width integer
---@return string
function InfoPanelBuffers:getFitBytes(bufer_count, width)
	if bufer_count == 0 then
		return ""
	end

	local data_amount = bufer_count * BUFFER_SIZE

	for _, unit in ipairs(InformationUnits) do
		local bytes = self:fitNumber(data_amount, " " .. unit, width)

		if bytes then
			return bytes
		end

		data_amount = data_amount / 1024
	end

	return string.format("%.1e GB", bufer_count * BUFFER_SIZE / 1024 / 1024)
end

---@param value number
---@param postfix string
---@param width integer
---@return string?
function InfoPanelBuffers:fitNumber(value, postfix, width)
	width = width - 2

	for i = 2, 0, -1 do
		local num = string.format("%." .. i .. "f", value):gsub("(%d+[,.]%d-)0*$", "%1"):gsub("[,.]$", "")
		local test = num .. postfix

		if self.fontS:getWidth(test) <= width then
			return test
		end
	end

	return nil
end

---@param title string
---@param isTotal boolean?
---@return CompositeObject
function InfoPanelBuffers:createRow(title, isTotal)
	self:createDivider(isTotal)

	local new_row = self:createChild "Container" {
		w = "fill",
		h = "hug",
		growth = "horizontal",
		horizontal = "left",
		vertical = "center",
		gap = 5,
		padding = {0, 5}
	}

	new_row:createChild "Label" {
		w = 70,
		h = "hug",
		horizontal = "center",
		text = title,
		font = self.fontS,
		textColor = COLORS.INFO_BUFFERS_TEXT
	}

	for _ = 1, 4 do
		new_row:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "",
			font = self.fontS,
			textColor = COLORS.INFO_BUFFERS_TEXT
		}
	end

	return new_row
end

---@param isTotal boolean?
function InfoPanelBuffers:createDivider(isTotal)
	self:createChild "Container" {
		w = "fill",
		h = 1,
		color = isTotal and COLORS.INFO_BUFFERS_DIVIDER_SUMUP or COLORS.INFO_BUFFERS_DIVIDER
	}
end

function InfoPanelBuffers:new()
	if not self.buffers.Total then
		local font = love.graphics.newFont(self.font, 17)

		self:createChild "Label" {
			text = "No buffers utilized.",
			font = font,
			w = "fill",
			horizontal = "left",
			textColor = COLORS.INFO_BUFFERS_TEXT
		}

		self.r = 10

		return
	end

	self.fontS = love.graphics.newFont(self.font, 16)

	do
		local header = self:createChild "Container" {
			w = "fill",
			h = "hug",
			growth = "horizontal",
			horizontal = "left",
			vertical = "center",
			gap = 5,
			padding = {0, 5}
		}

		header:createChild "Container" {
			w = 70,
			h = "fill",
			padding = {5, 0}
		} : createChild "Button" {
			w = "fill",
			h = "fill",
			text = self.currentView[1],
			font = self.fontS,
			color = COLORS.INFO_BUFFERS_BUTTON_FILL,
			additionalColor = COLORS.INFO_BUFFERS_BUTTON_BORDER,
			textColor = COLORS.INFO_BUFFERS_BUTTON_TEXT,
			action = function ()
				self:toggleView()
			end
		}

		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "Hit",
			font = self.fontS,
			textColor = COLORS.INFO_BUFFERS_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "Read",
			font = self.fontS,
			textColor = COLORS.INFO_BUFFERS_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "Dirtied",
			font = self.fontS,
			textColor = COLORS.INFO_BUFFERS_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "Written",
			font = self.fontS,
			textColor = COLORS.INFO_BUFFERS_TEXT
		}

		self.header = header
	end

	if self.buffers.Shared then
		self.shared_row = self:createRow("Shared")
	end

	if self.buffers.Local then
		self.local_row = self:createRow("Local")
	end

	if self.buffers.Temp then
		self.temp_row = self:createRow("Local")
	end

	if #self.objects > 3 then
		self.total_row = self:createRow("Total", true)
	end
end

return InfoPanelBuffers