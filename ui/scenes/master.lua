local gui = require("libs.stellargui")

local font_L = love.graphics.newFont("assets/font.ttf", 26)
local font_M = love.graphics.newFont("assets/font.ttf", 18)

love.graphics.setDefaultFilter("linear")

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

local malyar_image = love.graphics.newImage("assets/malyar.png")
malyar_image:setFilter("linear", "linear", 4)

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

--#endregion

return canvas