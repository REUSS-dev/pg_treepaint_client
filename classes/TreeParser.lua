-- classes/TreeParser.lua

local json = require("libs.json")

-- docs



-- consts



-- class

---@class TreeParser
local TreeParser = {}
TreeParser.__index = TreeParser

function TreeParser:parse(tree)
	local parsed = {}

	tree = json.decode(tree)

	parsed = tree

	return parsed
end

function TreeParser:new()
	local new_parser = {}

	setmetatable(new_parser, TreeParser)

	return new_parser
end

setmetatable(TreeParser, {__call = TreeParser.new})

return TreeParser