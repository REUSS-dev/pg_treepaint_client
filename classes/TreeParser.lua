-- classes/TreeParser.lua

local json = require("libs.json")

local TreeNormalizer = require("classes.TreeNormalizer")
local QueryProcessor = require("classes.QueryProcessor")
local PlanProcessor = require("classes.PlanProcessor")
local TextParser = require("classes.TextParser")

--#endregion

local function fix_data(data)
	if data:sub(1, 1) ~= "[" or data:sub(-1, -1) == "]" then
		return data
	end

	return data .. "}" .. "]"
end

-- class

---@class TreeParser
---@field normalizer TreeNormalizer
---@field queryProcessor QueryProcessor
---@field processor PlanProcessor
---@field textParser TextParser
local TreeParser = {}
TreeParser.__index = TreeParser

---@param tree string
---@return DumpedPlan?
---@return string? error
function TreeParser:parse(tree)
	tree = self.normalizer:normalize(tree)

	local _, _, nonspace = string.find(tree, "(%S)")

	local success, plan

	if nonspace == "[" or nonspace == "{" then
		success, plan = pcall(self.parseJSON, self, tree)
	else
		success, plan = pcall(self.parseText, self, tree)
	end

	if not success then
		return nil, plan --[[@as string]]
	end

	if not plan then
		return nil
	end ---@cast plan table

	plan = plan[1] or plan
	local dump = self.processor:process(plan)

	if plan["Rewritten Query Tree"] then
		dump.query = {}

		dump.query.rewritten = self.queryProcessor:process(plan["Rewritten Query Tree"])
	end

	return dump
end

--#region Explain format parsers

---@param json_string string
---@return table?
function TreeParser:parseJSON(json_string)
	json_string = json_string:gsub("\n(%S)", "%1")

	local success, tree = pcall(json.decode, fix_data(json_string))

	if not success then
		love.window.showMessageBox("Error", "Failed to parse JSON plan data.\nError: " .. tostring(tree), "warning")
		return
	end

	-- 64-bit integer to string
	local plan = tree[1] or tree
	if type(plan["Query Identifier"]) == "number" then
		plan["Query Identifier"] = string.match(json_string, "\"Query Identifier\":%s*(%-?%d+),")
	end

	tree.tp_format = "json"
	return tree
end

---@param text string
---@return table?
function TreeParser:parseText(text)
	local success, tree = pcall(self.textParser.parse, self.textParser, text)

	if not success then
		love.window.showMessageBox("Error", "Failed to parse plan data.\nError: " .. tostring(tree), "warning")
		return
	end

	print(json.encode(tree[1]["Plan"]))

	tree.tp_format = "text"
	return tree
end

--#endregion

function TreeParser:new()
	local new_parser = {}

	setmetatable(new_parser, TreeParser)

	self.normalizer = TreeNormalizer()
	self.queryProcessor = QueryProcessor()
	self.processor = PlanProcessor()
	self.textParser = TextParser()

	return new_parser
end

setmetatable(TreeParser, {__call = TreeParser.new})

return TreeParser