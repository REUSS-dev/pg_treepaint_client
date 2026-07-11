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
	if self.shared_row then
		self.shared_row.objects[2]:setText(self.buffers.Shared.hit ~= 0 and tostring(self.buffers.Shared.hit) or "")
		self.shared_row.objects[3]:setText(self.buffers.Shared.read ~= 0 and tostring(self.buffers.Shared.read) or "")
		self.shared_row.objects[4]:setText(self.buffers.Shared.dirtied ~= 0 and tostring(self.buffers.Shared.dirtied) or "")
		self.shared_row.objects[5]:setText(self.buffers.Shared.written ~= 0 and tostring(self.buffers.Shared.written) or "")
	end

	if self.local_row then
		self.local_row.objects[2]:setText(self.buffers.Local.hit ~= 0 and tostring(self.buffers.Local.hit) or "")
		self.local_row.objects[3]:setText(self.buffers.Local.read ~= 0 and tostring(self.buffers.Local.read) or "")
		self.local_row.objects[4]:setText(self.buffers.Local.dirtied ~= 0 and tostring(self.buffers.Local.dirtied) or "")
		self.local_row.objects[5]:setText(self.buffers.Local.written ~= 0 and tostring(self.buffers.Local.written) or "")
	end

	if self.temp_row then
		self.temp_row.objects[3]:setText(self.buffers.Temp.read ~= 0 and tostring(self.buffers.Temp.read) or "")
		self.temp_row.objects[5]:setText(self.buffers.Temp.written ~= 0 and tostring(self.buffers.Temp.written) or "")
	end

	if self.total_row then
		self.total_row.objects[2]:setText(self.buffers.Total.hit ~= 0 and tostring(self.buffers.Total.hit) or "")
		self.total_row.objects[3]:setText(self.buffers.Total.read ~= 0 and tostring(self.buffers.Total.read) or "")
		self.total_row.objects[4]:setText(self.buffers.Total.dirtied ~= 0 and tostring(self.buffers.Total.dirtied) or "")
		self.total_row.objects[5]:setText(self.buffers.Total.written ~= 0 and tostring(self.buffers.Total.written) or "")
	end
end

function InfoPanelBuffers:populatePercent()
	if self.shared_row then
		self.shared_row.objects[2]:setText(self:getFitPercent(self.buffers.Shared.hit / self.buffers.Shared.total, self.shared_row.objects[2].w))
		self.shared_row.objects[3]:setText(self:getFitPercent(self.buffers.Shared.read / self.buffers.Shared.total, self.shared_row.objects[3].w))
		self.shared_row.objects[4]:setText(self:getFitPercent(self.buffers.Shared.dirtied / self.buffers.Shared.total, self.shared_row.objects[4].w))
		self.shared_row.objects[5]:setText(self:getFitPercent(self.buffers.Shared.written / self.buffers.Shared.total, self.shared_row.objects[5].w))
	end

	if self.local_row then
		self.local_row.objects[2]:setText(self:getFitPercent(self.buffers.Local.hit / self.buffers.Local.total, self.local_row.objects[2].w))
		self.local_row.objects[3]:setText(self:getFitPercent(self.buffers.Local.read / self.buffers.Local.total, self.local_row.objects[3].w))
		self.local_row.objects[4]:setText(self:getFitPercent(self.buffers.Local.dirtied / self.buffers.Local.total, self.local_row.objects[4].w))
		self.local_row.objects[5]:setText(self:getFitPercent(self.buffers.Local.written / self.buffers.Local.total, self.local_row.objects[5].w))
	end

	if self.temp_row then
		self.temp_row.objects[3]:setText(self:getFitPercent(self.buffers.Temp.read / self.buffers.Temp.total, self.temp_row.objects[3].w))
		self.temp_row.objects[5]:setText(self:getFitPercent(self.buffers.Temp.written / self.buffers.Temp.total, self.temp_row.objects[5].w))
	end

	if self.total_row then
		self.total_row.objects[2]:setText(self:getFitPercent(self.buffers.Total.hit / self.buffers.Total.total, self.total_row.objects[2].w))
		self.total_row.objects[3]:setText(self:getFitPercent(self.buffers.Total.read / self.buffers.Total.total, self.total_row.objects[3].w))
		self.total_row.objects[4]:setText(self:getFitPercent(self.buffers.Total.dirtied / self.buffers.Total.total, self.total_row.objects[4].w))
		self.total_row.objects[5]:setText(self:getFitPercent(self.buffers.Total.written / self.buffers.Total.total, self.total_row.objects[5].w))
	end
end

function InfoPanelBuffers:populateBytes()
	if self.shared_row then
		self.shared_row.objects[2]:setText(self:getFitBytes(self.buffers.Shared.hit, self.shared_row.objects[2].w))
		self.shared_row.objects[3]:setText(self:getFitBytes(self.buffers.Shared.read, self.shared_row.objects[3].w))
		self.shared_row.objects[4]:setText(self:getFitBytes(self.buffers.Shared.dirtied, self.shared_row.objects[4].w))
		self.shared_row.objects[5]:setText(self:getFitBytes(self.buffers.Shared.written, self.shared_row.objects[5].w))
	end

	if self.local_row then
		self.local_row.objects[2]:setText(self:getFitBytes(self.buffers.Local.hit, self.local_row.objects[2].w))
		self.local_row.objects[3]:setText(self:getFitBytes(self.buffers.Local.read, self.local_row.objects[3].w))
		self.local_row.objects[4]:setText(self:getFitBytes(self.buffers.Local.dirtied, self.local_row.objects[4].w))
		self.local_row.objects[5]:setText(self:getFitBytes(self.buffers.Local.written, self.local_row.objects[5].w))
	end

	if self.temp_row then
		self.temp_row.objects[3]:setText(self:getFitBytes(self.buffers.Temp.read, self.temp_row.objects[3].w))
		self.temp_row.objects[5]:setText(self:getFitBytes(self.buffers.Temp.written, self.temp_row.objects[5].w))
	end

	if self.total_row then
		self.total_row.objects[2]:setText(self:getFitBytes(self.buffers.Total.hit, self.total_row.objects[2].w))
		self.total_row.objects[3]:setText(self:getFitBytes(self.buffers.Total.read, self.total_row.objects[3].w))
		self.total_row.objects[4]:setText(self:getFitBytes(self.buffers.Total.dirtied, self.total_row.objects[4].w))
		self.total_row.objects[5]:setText(self:getFitBytes(self.buffers.Total.written, self.total_row.objects[5].w))
	end
end

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

function InfoPanelBuffers:getFitPercent(value, width)
	if value < EPS then
		return ""
	end

	value = value * 100

	return self:fitNumber(value, "%", width) or "?"
end

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