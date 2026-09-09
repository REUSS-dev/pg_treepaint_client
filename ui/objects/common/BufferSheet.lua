-- BufferSheet

local gui = require("stellargui")

local EPS = 10^-14
local BUFFER_SIZE = BUFFER_SIZE / 1024

---@enum ViewState
local ViewState = {
	PAGE = "123",
	PERCENT = "%",
	BYTES = "KB",
	IO = "I/O"
}

local InformationUnits = {"kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "RB", "QB"}
local TimeUnits = {"ms", "s", "m", "h", "d", "m", "y"}
local TimeUnitsMaxAmount = {1000, 60, 60, 24, 30, 12}

local DEFAULT_VIEW_STATE = ViewState.PAGE

local FONT_STEP = 1
local FONT_MIN_SIZE = 12

---@class BufferSheet : CompositeObject
---@field CompositeObject CompositeObject
---@field buffers BufferTable Active buffers table that is being drawn
---@field header CompositeObject Container with Buffer Sheet header labels
---@field shared_row {objects: Label[]}? Container with Shared Buffer row. May be missing if active buffers table does not contain Shared buffers
---@field local_row {objects: Label[]}? Container with Local Buffer row. May be missing if active buffers table does not contain Local buffers
---@field temp_row {objects: Label[]}? Container with Temp Buffer row. May be missing if active buffers table does not contain Temp buffers
---@field total_row {objects: Label[]}? Container with Total Buffer row. Only present if 2 or more other rows are present
---@field populatedView ViewState? View state what Buffer Sheet rows' Labels are populated with. nil if none
---@field group string Group that identifies Buffer Sheet object. All Buffer Sheets that share one group will share current ViewState
local BufferSheet = {
	name = "BufferSheet",
	extends = "CompositeObject",
	rules = {
		{{"buffers"}, "buffers"},
		{{"group"}, "group"},
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

		color = COLORS.BUFFER_TABLE,
		font = "default 16",

		group = "default"
	},

	currentView = {}
}

function BufferSheet:paint(...)
	self:resolveView()
	self.CompositeObject.paint(self)
end

function BufferSheet:toggleView()
	local current_view = self.currentView[self.group]

	if current_view == ViewState.PAGE then
		self.currentView[self.group] = ViewState.PERCENT
	elseif current_view == ViewState.PERCENT then
		self.currentView[self.group] = ViewState.BYTES
	elseif current_view == ViewState.BYTES then
		if self.buffers.Total.io_read then
			self.currentView[self.group] = ViewState.IO
		else
			self.currentView[self.group] = ViewState.PAGE
		end
	elseif current_view == ViewState.IO then
		self.currentView[self.group] = ViewState.PAGE
	end

	self:redraw()
end

function BufferSheet:resolveView()
	if not self.header then
		return
	end ---@cast self +{header:{objects: {objects: {objects: {[1]: Label}}[]}[]}}

	local current_view = self.currentView[self.group]

	if current_view == self.populatedView then
		return
	end

	if current_view == ViewState.PAGE then
		self:populatePage()
		self.header.objects[1].objects[1].objects[1]:setText(ViewState.PAGE)
	elseif current_view == ViewState.PERCENT then
		self:populatePercent()
		self.header.objects[1].objects[1].objects[1]:setText(ViewState.PERCENT)
	elseif current_view == ViewState.BYTES then
		self:populateBytes()
		self.header.objects[1].objects[1].objects[1]:setText(ViewState.BYTES)
	elseif current_view == ViewState.IO then
		self:populateIO()
		self.header.objects[1].objects[1].objects[1]:setText(ViewState.IO)
	end

	self.populatedView = current_view
end

--#region View State Page

function BufferSheet:populatePage()
	self:populatePageRow(self.shared_row, self.buffers.Shared)
	self:populatePageRow(self.local_row, self.buffers.Local)
	self:populatePageRow(self.temp_row, self.buffers.Temp)
	self:populatePageRow(self.total_row, self.buffers.Total)
end

---@param row {objects: Label[]} CompositeObject of Labels
---@param buffer_values BufferStats
function BufferSheet:populatePageRow(row, buffer_values)
	if row then
		row.objects[2]:setText(self:getFitPage(buffer_values.hit, row.objects[2]))
		row.objects[3]:setText(self:getFitPage(buffer_values.read, row.objects[3]))
		row.objects[4]:setText(self:getFitPage(buffer_values.dirtied, row.objects[4]))
		row.objects[5]:setText(self:getFitPage(buffer_values.written, row.objects[5]))
	end
end

---@param value integer
---@param object Label
---@return string
function BufferSheet:getFitPage(value, object)
	if value == 0 then
		return ""
	end

	if self.font:getWidth(value) <= object.w then
		return tostring(value)
	end

	local storage = gui.getFontStorage()
	local name, size = string.match(self.default.font, "(.-).(%d+)$")

	size = tonumber(size) - FONT_STEP
	local new_font = storage:getFont(name, size)

	while size >= FONT_MIN_SIZE do
		if new_font:getWidth(value) <= object.w then
			break
		end

		size = size - FONT_STEP
		new_font = storage:getFont(name, size)
	end

	object.font = new_font
	return tostring(value)
end

--#endregion

--#region View State Percent

function BufferSheet:populatePercent()
	self:populatePercentRow(self.shared_row, self.buffers.Shared)
	self:populatePercentRow(self.local_row, self.buffers.Local)
	self:populatePercentRow(self.temp_row, self.buffers.Temp)
	self:populatePercentRow(self.total_row, self.buffers.Total)
end

---@param row {objects: Label[]} CompositeObject of Labels
---@param buffer_values BufferStats
function BufferSheet:populatePercentRow(row, buffer_values)
	if row then
		row.objects[2]:setText(self:getFitPercent(buffer_values.hit / buffer_values.total, row.objects[2]))
		row.objects[3]:setText(self:getFitPercent(buffer_values.read / buffer_values.total, row.objects[3]))
		row.objects[4]:setText(self:getFitPercent(buffer_values.dirtied / buffer_values.total, row.objects[4]))
		row.objects[5]:setText(self:getFitPercent(buffer_values.written / buffer_values.total, row.objects[5]))
	end
end

---@param value number
---@param label Label
---@return string
function BufferSheet:getFitPercent(value, label)
	if value < EPS then
		return ""
	end

	value = value * 100

	return self:fitNumber(value, "%", label) or "?"
end

--#endregion

--#region View State Bytes

function BufferSheet:populateBytes()
	self:populateBytesRow(self.shared_row, self.buffers.Shared)
	self:populateBytesRow(self.local_row, self.buffers.Local)
	self:populateBytesRow(self.temp_row, self.buffers.Temp)
	self:populateBytesRow(self.total_row, self.buffers.Total)
end

---@param row {objects: Label[]} CompositeObject of Labels
---@param buffer_values BufferStats
function BufferSheet:populateBytesRow(row, buffer_values)
	if row then
		row.objects[2]:setText(self:getFitBytes(buffer_values.hit, row.objects[2]))
		row.objects[3]:setText(self:getFitBytes(buffer_values.read, row.objects[3]))
		row.objects[4]:setText(self:getFitBytes(buffer_values.dirtied, row.objects[4]))
		row.objects[5]:setText(self:getFitBytes(buffer_values.written, row.objects[5]))
	end
end

---@param bufer_count integer
---@param label Label
---@return string
function BufferSheet:getFitBytes(bufer_count, label)
	if bufer_count == 0 then
		return ""
	end

	local data_amount = bufer_count * BUFFER_SIZE

	for _, unit in ipairs(InformationUnits) do
		local bytes = self:fitNumber(data_amount, " " .. unit, label)

		if bytes then
			return bytes
		end

		data_amount = data_amount / 1024
	end

	return string.format("%.1e GB", bufer_count * BUFFER_SIZE / 1024 / 1024)
end

--#endregion

--#region View State IO

function BufferSheet:populateIO()
	self:populateIORow(self.shared_row, self.buffers.Shared)
	self:populateIORow(self.local_row, self.buffers.Local)
	self:populateIORow(self.temp_row, self.buffers.Temp)
	self:populateIORow(self.total_row, self.buffers.Total)
end

---@param row {objects: Label[]} CompositeObject of Labels
---@param buffer_values BufferStats
function BufferSheet:populateIORow(row, buffer_values)
	if row then
		row.objects[2]:setText("")
		row.objects[3]:setText(self:getFitIO(buffer_values.io_read, row.objects[3]))
		row.objects[4]:setText("")
		row.objects[5]:setText(self:getFitIO(buffer_values.io_write, row.objects[5]))
	end
end

---@param time_ms number
---@param label Label
---@return string
function BufferSheet:getFitIO(time_ms, label)
	if time_ms == 0 then
		return self:fitNumber(0, " " .. TimeUnits[1], label) or ""
	end

	local time = time_ms

	for i, unit in ipairs(TimeUnits) do
		local timestring = self:fitNumber(time, " " .. unit, label)

		if timestring then
			return timestring
		end

		time = time / TimeUnitsMaxAmount[i]
	end

	return string.format("%.1e d", time_ms / 1000 / 60 / 60 / 24)
end

--#endregion

---@param value number
---@param postfix string
---@param label Label
---@return string?
function BufferSheet:fitNumber(value, postfix, label)
	if label.font ~= self.font then
		label.font = self.font
	end

	local width = label.w - 2

	for i = 2, 0, -1 do
		local num = string.format("%." .. i .. "f", value):gsub("(%d+[,.]%d-)0*$", "%1"):gsub("[,.]$", "")
		local test = num .. postfix

		if self.font:getWidth(test) <= width then
			return test
		end
	end

	return nil
end

---@param title string
---@param isTotal boolean?
---@return CompositeObject
function BufferSheet:createRow(title, isTotal)
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
		font = self.font,
		textColor = COLORS.BUFFER_TEXT
	}

	for _ = 1, 4 do
		new_row:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "",
			font = self.font,
			textColor = COLORS.BUFFER_TEXT
		}
	end

	return new_row
end

---@param isTotal boolean?
function BufferSheet:createDivider(isTotal)
	self:createChild "Container" {
		w = "fill",
		h = 1,
		color = isTotal and COLORS.BUFFER_DIVIDER_SUMUP or COLORS.BUFFER_DIVIDER
	}
end

function BufferSheet:new()
	if not self.currentView[self.group] then
		self.currentView[self.group] = DEFAULT_VIEW_STATE
	end

	if not self.buffers.Total then
		self:createChild "Label" {
			text = "buffers.no_buffers",
			font = self.font,
			w = "fill",
			horizontal = "left",
			textColor = COLORS.BUFFER_TEXT
		}

		self.r = 10

		return
	end

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
			font = self.font,
			color = COLORS.BUFFER_BUTTON_FILL,
			additionalColor = COLORS.BUFFER_BUTTON_BORDER,
			textColor = COLORS.BUFFER_BUTTON_TEXT,
			action = function ()
				self:toggleView()
			end
		}

		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "buffers.Hit",
			font = self.font,
			textColor = COLORS.BUFFER_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "buffers.Read",
			font = self.font,
			textColor = COLORS.BUFFER_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "buffers.Dirtied",
			font = self.font,
			textColor = COLORS.BUFFER_TEXT
		}
		header:createChild "Label" {
			w = "fill",
			h = "hug",
			horizontal = "right",
			text = "buffers.Written",
			font = self.font,
			textColor = COLORS.BUFFER_TEXT
		}

		self.header = header
	end

	if self.buffers.Shared then
		self.shared_row = self:createRow("buffers.Shared")
	end

	if self.buffers.Local then
		self.local_row = self:createRow("buffers.Local")
	end

	if self.buffers.Temp then
		self.temp_row = self:createRow("buffers.Temp")
	end

	if #self.objects > 3 then
		self.total_row = self:createRow("buffers.total", true)
	end
end

return BufferSheet