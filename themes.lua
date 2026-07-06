-- themes.lua

local DEFAULT_THEME = "dark"

local themes = {}

setmetatable(themes, { __index = function (self, _)
	return self[DEFAULT_THEME]
end})

-- dark theme (default)

---@class Colors
local theme_dark = {
	BACKGROUND = {15/255, 15/255, 15/255, 255/255},
	TOP_PANEL = {42/255, 42/255, 42/255, 255/255},
	LABEL_TREEPAINT = {200/255, 200/255, 200/255, 255/255},
	LABEL_TREEMOTTO = {180/255, 180/255, 180/255, 255/255},

	TCP_ACTIVE = {0, 100/255, 0, 1},
	TCP_ACTIVE_BORDER = {100/255, 200/255, 100/255, 1},
	TCP_INACTIVE = {100/255, 0, 0, 1},
	TCP_INACTIVE_BORDER = {200/255, 100/255, 100/255, 1},

	PASTE_FILL = {100/255, 100/255, 0, 1},
	PASTE_BORDER = {200/255, 200/255, 100/255, 1},
	PASTE_TEXT = {1, 1, 1, 1},

	NODE_FILL = {32/255, 32/255, 32/255, 255/255},
	NODE_BORDER = {1, 1, 1, 1},
	NODE_HOVER = {40/255, 40/255, 40/255, 255/255},
	NODE_SELECT = {64/255, 64/255, 64/255, 255/255},
	NODE_TEXT = {1, 1, 1, 1},
	NODE_TEXT_DESC = {0.8, 0.8, 0.8, 1},

	INFO_PANEL = {32/255, 32/255, 32/255, 255/255},
	INFO_PANEL_ELEMENT = {42/255, 42/255, 42/255, 255/255},
	INFO_PANEL_BUTTON = {64/255, 64/255, 64/255, 255/255},
	INFO_PANEL_DIVIDER = {154/255, 154/255, 154/255, 255/255},

	INFO_BUFFERS = {64/255, 64/255, 64/255, 255/255},
	INFO_BUFFERS_DIVIDER = {127/255, 127/255, 127/255, 255/255},
	INFO_BUFFERS_DIVIDER_SUMUP = {255/255, 255/255, 255/255, 255/255},
	INFO_BUFFERS_TEXT = {255/255, 255/255, 255/255, 255/255},
	INFO_BUFFERS_BUTTON_FILL = {76/255, 138/255, 210/255, 255/255},
	INFO_BUFFERS_BUTTON_BORDER = {163/255, 206/255, 255/255, 255/255},
	INFO_BUFFERS_BUTTON_TEXT = {255/255, 255/255, 255/255, 255/255},

	CONNECTION = {1, 1, 1, 1},
	CONNECTION_HOVER = {1, 0.75, 0, 0.75},
	CONNECTION_PARENT = {1, 0, 0, 1},
	CONNECTION_CHILD = {0, 1, 0, 1},

	NODE_AGGREGATE = {0.75, 0.5, 0, 1},
	NODE_BITMAP_HEAP_SCAN = {0.25, 1, 1, 1},
	NODE_HASH = {0.75, 0, 0.75, 1},
	NODE_HASH_JOIN = {0.5, 0, 0.5, 1},
	NODE_INDEX_ONLY_SCAN = {0, 0.75, 0, 1},
	NODE_INDEX_SCAN = {0.5, 1, 0.5, 1},
	NODE_NESTED_LOOP = {0.5, 0.5, 1, 1},
	NODE_SEQ_SCAN = {0.75, 0.1, 0.1, 1},
	NODE_SORT = {0, 0.75, 0.75, 1},
}

themes["dark"] = theme_dark

-- light theme

local theme_light = {
	BACKGROUND = {240/255, 240/255, 240/255, 255/255},
	TOP_PANEL = {213/255, 213/255, 213/255, 255/255},
	LABEL_TREEPAINT = {55/255, 55/255, 55/255, 255/255},
	LABEL_TREEMOTTO = {75/255, 75/255, 75/255},

	NODE_FILL = {223/255, 223/255, 223/255, 255/255},
	NODE_BORDER = {0, 0, 0, 1},
	NODE_TEXT = {0, 0, 0, 1},
	NODE_TEXT_DESC = {0.2, 0.2, 0.2, 1},

	CONNECTION = {0, 0, 0, 1}
}

setmetatable(theme_light, { __index = theme_dark })

themes["light"] = theme_light

---@class Colors
---@field BACKGROUND ColorTable Diagram background color
---@field TOP_PANEL ColorTable Main color of top panel
---@field LABEL_TREEPAINT ColorTable Color of "TreePaint" logo label on the top panel
---@field LABEL_TREEMOTTO ColorTable Color of "A PostgreSQL Tree Visualization Tool" label under the logo label
---@field NODE_FILL ColorTable Default color of node inside fill
---@field NODE_BORDER ColorTable Default color of node border
---@field NODE_TEXT ColorTable Default node text color
---@field NODE_TEXT_DESC ColorTable Default node text secondary color
---@field CONNECTION ColorTable Color of connections between nodes on a diagram
COLORS = themes[UI_THEME]