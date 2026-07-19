---@diagnostic disable-next-line: different-requires
local gui = require("libs.stellargui")

-- graphics

gui.setDefaultFont("assets/font.ttf")

local malyar_image = love.graphics.newImage("assets/malyar.png")

love.graphics.setBackgroundColor(COLORS.BACKGROUND)

-- init

local TCPListener = require("classes.TCPListener")

-- scene

local canvas = gui.createCanvas{
	growth = "vertical",
	vertical = "top",
	padding = {0, 0, 0, 0},
	gap = 0
}

--#region top panel

local top_panel = gui.Container{
	w = "fill",
	h = 75,
	color = COLORS.TOP_PANEL,
	padding = {10, 10, 10, 10},
	growth = "horizontal",
	horizontal = "left",
	vertical = "top"
}
canvas:add(top_panel)

local malyar = gui.Image{
	image = malyar_image,
	w = "hug",
	h = "fill"
}

top_panel:add(malyar)

local label_container = gui.Container{
	growth = "vertical",
	gap = 3,
	horizontal = "left"
}

local treepaint_label = gui.Label{
	text = "TreePaint",
	font = "default 26",
	text_color = COLORS.LABEL_TREEPAINT
}
local treepaint_desc = gui.Label{
	text = "A PostgreSQL Tree Visualization Tool",
	font = "default 18",
	text_color = COLORS.LABEL_TREEMOTTO
}

label_container:add(treepaint_label)
label_container:add(treepaint_desc)

top_panel:add(label_container)

local autocontainer = gui.Container{w = "fill"}
top_panel:add(autocontainer)

local paste = gui.PasteApplet{
	w = 140,
	font = "default 18"
}
top_panel:add(paste)

local tcp = gui.TCPApplet{
	tcp = TCPListener(CLIENT_IP, CLIENT_PORT):start(),
	w = 180,
	r = 5,
	font = "default 18"
}
top_panel:add(tcp)

--#endregion

--#region

local main_panel = canvas:createChild "MainPanel" {}

main_panel:registerDiagramObject(tcp)
main_panel:registerDiagramObject(paste)

--#endregion

return canvas