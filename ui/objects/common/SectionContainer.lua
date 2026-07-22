-- SectionContainer

---@class SectionContainer : CompositeObject
---@field CompositeObject CompositeObject
---@field divider CompositeObject
---@field contents CompositeObject
---@field collapseButton SectionCollapse
---@field font {title: love.Font, text: love.Font}
---@field title string?
---@field group string
---@field collapsible boolean
local SectionContainer = {
	name = "SectionContainer",
	extends = "CompositeObject",
	rules = {
		{{"title"}, "title"},
		{{"group"}, "group"},
		{{"collapse", "collapsible"}, "collapsible"},
	},
	default = {
		w = "fill",
		h = "hug",
		growth = "vertical",
		gap = 5,
		horizontal = "left",
		vertical = "top",
		r = 10,
		padding = {10, 8},

		color = COLORS.SECTION_CONTAINER,
		textColor = COLORS.SECTION_CONTAINER_TITLE,
		font = {title = "default 20", text = "default 17"},

		collapsible = true
	},

	sectionStates = {
		["Timing Info"] = true,
		["Buffers Info"] = true
	}
}

function SectionContainer:paint(...)
	self:resolveState()
	self.CompositeObject.paint(self)
end

function SectionContainer:getContentsContainer()
	return self.contents
end

---@param prefix string
---@param value (string|integer)?
---@param greyed boolean?
---@return SectionContainer
function SectionContainer:addTextProtected(prefix, value, greyed)
	if not value then
		return self
	end

	return self:addText(prefix .. value, greyed)
end

---@param text string
---@param greyed boolean?
---@return SectionContainer
function SectionContainer:addText(text, greyed)
	self.contents:createChild "Label" {
		w = "fill",
		h = "hug",
		horizontal = "left",
		text = text,
		font = self.font.text,
		textColor = greyed and COLORS.NODE_TEXT_GREYED or COLORS.NODE_TEXT
	}

	return self
end

function SectionContainer:addObject(obj)
	self.contents:add(obj)

	return self
end

function SectionContainer:toggleCollapse()
	if not self.collapsible then
		return
	end

	self.sectionStates[self.group] = not self.sectionStates[self.group]
	self:resolveState()
end

function SectionContainer:isCollapsed()
	return not self.collapsible or not self.sectionStates[self.group]
end

function SectionContainer:resolveState()
	if not self.collapsible then
		return
	end

	if self:isCollapsed() then
		self.contents:hide()
		self.divider:hide()
	else
		self.contents:show()
		self.divider:show()
	end
end

function SectionContainer:new()
	self.group = self.group or self.title

	if self.collapsible then
		assert(self.title, "Element \"title\" is required for a collapsible SectionContainer object")

		if self.sectionStates[self.group] == nil then
			self.sectionStates[self.group] = false
		end

		local top_container = self:createChild "Container" {
			growth = "horizontal",
			w = "fill"
		}

		top_container:createChild "Label" {
			text = self.title,
			font = self.font.title,
			w = "fill",
			horizontal = "left",
			textColor = self.palette.text
		}

		self.collapseButton = top_container:createChild "SectionCollapse" {
			target = self
		}

		self.divider = self:createChild "Container" {
			w = "fill",
			padding = {0, 0, 25, 0}
		} : createChild "Container" {
			w = "fill",
			h = 1,
			color = COLORS.SECTION_CONTAINER_DIVIDER
		}
	else
		if self.title then
			self:createChild "Label" {
				text = self.title,
				font = self.font.title,
				w = "fill",
				horizontal = "left",
				textColor = self.palette.text
			}

			self.divider = self:createChild "Container" {
				w = "fill",
				h = 1,
				color = COLORS.SECTION_CONTAINER_DIVIDER
			}
		end
	end

	self.contents = self:createChild "Container" {
		w = "fill",
		gap = 2
	}
end

return SectionContainer