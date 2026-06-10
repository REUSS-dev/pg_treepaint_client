local gui = require("libs.stellargui")

-- graphics

local font_L = love.graphics.newFont("assets/font.ttf", 26)
local font_M = love.graphics.newFont("assets/font.ttf", 18)
local font_S = love.graphics.newFont("assets/font.ttf", 16)

local malyar_image = love.graphics.newImage("assets/malyar.png")
malyar_image:setFilter("linear", "linear", 4)

-- init

local TCPListener = require("classes.TCPListener")

local DiagramNode = gui.getObjectDescriptor("DiagramNode")
DiagramNode.font = font_M
DiagramNode.desc_font = font_S

-- scene

local canvas = gui.createCanvas{
	growth = "vertical",
	vertical = "top",
	colors = {
		fill = {24/255, 24/255, 24/255, 255/255}
	},
	padding = {0, 0, 0, 0}
}

--#region top panel

local top_panel = gui.Container{
	w = "fill",
	h = 75,
	color = {42/255, 42/255, 42/255, 255/255},
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
	font = font_L,
	text_color = {200/255, 200/255, 200/255}
}
local treepaint_desc = gui.Label{
	text = "A PostgreSQL Tree Visualization Tool",
	font = font_M,
	text_color = {180/255, 180/255, 180/255}
}

label_container:add(treepaint_label)
label_container:add(treepaint_desc)

top_panel:add(label_container)

local autocontainer = gui.Container{w = "fill"}
top_panel:add(autocontainer)

local paste = gui.PasteApplet{
	w = 140,
	font = font_M
}
top_panel:add(paste)

local tcp = gui.TCPApplet{
	tcp = TCPListener(CLIENT_IP, CLIENT_PORT):start(),
	w = 180,
	r = 5,
	font = font_M
}
top_panel:add(tcp)

--#endregion

--#region

local main_panel = gui.Container{
	w = "fill",
	h = "fill",
	growth = "horizontal"
}
canvas:add(main_panel)

local diagram_draw = gui.DiagramArea{
	w = "fill",
	h = "fill",
	font = font_M
}
main_panel:add(diagram_draw)
tcp:registerDiagramObject(diagram_draw)
paste:registerDiagramObject(diagram_draw)

--#endregion

return canvas