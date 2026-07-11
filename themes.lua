-- themes.lua

---@alias ColorEntry ColorTable|string

local DEFAULT_THEME = "dark"

local themes = {}

setmetatable(themes, { __index = function (self, _)
	return self[DEFAULT_THEME]
end})

-- dark theme (default)

---@class Colors
local theme_dark = {
	COLOR_PRIMARY_0 = {15/255, 15/255, 15/255, 255/255},
	COLOR_PRIMARY_1 = {32/255, 32/255, 32/255, 255/255},
	COLOR_PRIMARY_2 = {42/255, 42/255, 42/255, 255/255},

	COLOR_SECONDARY_1 = {64/255, 64/255, 64/255, 255/255},

	COLOR_ACCENT_1 = {255/255, 255/255, 255/255, 255/255},
	COLOR_ACCENT_2 = {200/255, 200/255, 200/255, 255/255},
	COLOR_ACCENT_3 = {154/255, 154/255, 154/255, 255/255},
	COLOR_ACCENT_4 = {127/255, 127/255, 127/255, 255/255},

	COLOR_TEXT_1 = {255/255, 255/255, 255/255, 255/255},
	COLOR_TEXT_2 = {204/255, 204/255, 204/255, 255/255},
	COLOR_TEXT_3 = {180/255, 180/255, 180/255, 255/255},
	COLOR_TEXT_4 = {127/255, 127/255, 127/255, 255/255},

	BACKGROUND = "COLOR_PRIMARY_0",
	TOP_PANEL = "COLOR_PRIMARY_2",
	LABEL_TREEPAINT = "COLOR_TEXT_2",
	LABEL_TREEMOTTO = "COLOR_TEXT_3",

	TCP_ACTIVE = {0, 100/255, 0, 1},
	TCP_ACTIVE_BORDER = {100/255, 200/255, 100/255, 1},
	TCP_INACTIVE = {100/255, 0, 0, 1},
	TCP_INACTIVE_BORDER = {200/255, 100/255, 100/255, 1},
	TCP_TEXT = "COLOR_TEXT_1",

	PASTE_FILL = {100/255, 100/255, 0, 1},
	PASTE_BORDER = {200/255, 200/255, 100/255, 1},
	PASTE_TEXT = "COLOR_TEXT_1",

	NODE_FILL = "COLOR_PRIMARY_1",
	NODE_BORDER = "COLOR_ACCENT_1",
	NODE_HOVER = "COLOR_PRIMARY_2",
	NODE_SELECT = "COLOR_SECONDARY_1",
	NODE_TEXT = "COLOR_TEXT_1",
	NODE_TEXT_DESC = "COLOR_TEXT_2",
	NODE_TEXT_GREYED = "COLOR_TEXT_4",
	NODE_NAVIGATION = "COLOR_PRIMARY_2",
	NODE_NAVIGATION_ARROW = "COLOR_ACCENT_2",

	INFO_PANEL = "COLOR_PRIMARY_1",
	INFO_PANEL_TITLE = "COLOR_TEXT_1",
	INFO_PANEL_ELEMENT = "COLOR_PRIMARY_2",
	INFO_PANEL_BUTTON = "COLOR_SECONDARY_1",
	INFO_PANEL_DIVIDER = "COLOR_ACCENT_3",

	INFO_BUFFERS = "COLOR_SECONDARY_1",
	INFO_BUFFERS_DIVIDER = "COLOR_ACCENT_4",
	INFO_BUFFERS_DIVIDER_SUMUP = "COLOR_ACCENT_1",
	INFO_BUFFERS_TEXT = "COLOR_ACCENT_1",
	INFO_BUFFERS_BUTTON_FILL = {76/255, 138/255, 210/255, 255/255},
	INFO_BUFFERS_BUTTON_BORDER = {163/255, 206/255, 255/255, 255/255},
	INFO_BUFFERS_BUTTON_TEXT = "COLOR_ACCENT_1",

	CONNECTION = "COLOR_ACCENT_1",
	CONNECTION_HOVER = {1, 0.75, 0, 0.75},
	CONNECTION_PARENT = {1, 0, 0, 1},
	CONNECTION_CHILD = {0, 1, 0, 1},

	NODE_AGGREGATE = {0.75, 0.5, 0, 1},
	NODE_BITMAP_HEAP_SCAN = {0.25, 1, 1, 1},
	NODE_CTE_SCAN = {0.9, 1, 0, 1},
	NODE_HASH = {0.75, 0, 0.75, 1},
	NODE_HASH_JOIN = {0.5, 0, 0.5, 1},
	NODE_INDEX_ONLY_SCAN = {0, 0.75, 0, 1},
	NODE_INDEX_SCAN = {0.5, 1, 0.5, 1},
	NODE_NESTED_LOOP = {0.5, 0.5, 1, 1},
	NODE_SEQ_SCAN = {0.75, 0.1, 0.1, 1},
	NODE_SORT = {0, 0.75, 0.75, 1},

	NODE_GLOW = true
}

themes["dark"] = theme_dark

-- light theme

local theme_light = {
	COLOR_PRIMARY_0 = {223/255, 223/255, 223/255, 255/255},
	COLOR_PRIMARY_1 = {213/255, 213/255, 213/255, 255/255},
	COLOR_PRIMARY_2 = {200/255, 200/255, 200/255, 255/255},

	COLOR_SECONDARY_1 = {191/255, 191/255, 191/255, 255/255},

	COLOR_TEXT_1 = {0, 0, 0, 1},
	COLOR_TEXT_2 = {55/255, 55/255, 55/255, 255/255},
	COLOR_TEXT_3 = {75/255, 75/255, 75/255, 255/255},

	COLOR_ACCENT_1 = {0/255, 0/255, 0/255, 255/255},
	COLOR_ACCENT_2 = {55/255, 55/255, 55/255, 255/255},
	COLOR_ACCENT_3 = {101/255, 101/255, 101/255, 255/255},
	COLOR_ACCENT_4 = {127/255, 127/255, 127/255, 255/255},

	COLOR_TEXT_SATURATED = {242/255, 242/255, 242/255, 255/255},

	TCP_ACTIVE = {0, 155/255, 0, 1},
	TCP_TEXT = "COLOR_TEXT_SATURATED",

	PASTE_FILL = {155/255, 155/255, 0, 1},
	PASTE_BORDER = {200/255, 200/255, 100/255, 1},
	PASTE_TEXT = "COLOR_TEXT_SATURATED",

	INFO_BUFFERS_BUTTON_TEXT = "COLOR_TEXT_SATURATED",

	CONNECTION_PARENT = {1, 0.2, 0.2, 1},
	CONNECTION_CHILD = {0.2, 0.8, 0.2, 1},

	NODE_INDEX_SCAN = {0.5, 0.75, 0.5, 1},

	NODE_GLOW = false

}

setmetatable(theme_light, { __index = theme_dark })

themes["light"] = theme_light

---@class Colors
---@field BACKGROUND ColorEntry Diagram background color
---@field TOP_PANEL ColorEntry Main color of top panel
---@field LABEL_TREEPAINT ColorEntry Color of "TreePaint" logo label on the top panel
---@field LABEL_TREEMOTTO ColorEntry Color of "A PostgreSQL Tree Visualization Tool" label under the logo label
---@field NODE_FILL ColorEntry Default color of node inside fill
---@field NODE_BORDER ColorEntry Default color of node border
---@field NODE_TEXT ColorEntry Default node text color
---@field NODE_TEXT_DESC ColorEntry Default node text secondary color
---@field CONNECTION ColorEntry Color of connections between nodes on a diagram
COLORS = setmetatable({}, { __index = function (self, color)
	local theme_color = themes[UI_THEME][color]

	if type(theme_color) == "string" then
		self[color] = self[theme_color]
		return self[color]
	end

	self[color] = theme_color
	return theme_color
end})