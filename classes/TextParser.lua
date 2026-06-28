-- classes/TextParser.lua

--[[ Покрытие параметров
	ANALYZE: ON - ЕСТЬ, OFF - ЕСТЬ
	VERBOSE: ON - ЕСТЬ, OFF - ЕСТЬ
	COSTS: ON - ЕСТЬ, OFF - ЕСТЬ
	SETTINGS: ON - НЕТ, OFF - ЕСТЬ
	GENERIC_PLAN: ON - НЕТ, OFF - ЕСТЬ
	BUFFERS: ОN - ЕСТЬ, OFF - ЕСТЬ
	SERIALIZE: ON - НЕТ, OFF - ЕСТЬ
	WAL: ON - НЕТ (TIMING ON: НЕТ, TIMING OFF: НЕТ, BUFFERS ON: НЕТ, BUFFERS OFF: НЕТ), OFF - ЕСТЬ
	TIMING: ON - ЕСТЬ, OFF - НЕТ
	SUMMARY: ON - НЕТ, OFF - ЕСТЬ
	MEMORY: ON - НЕТ, OFF - ЕСТЬ
]]

-- consts

---@enum CustomParameters
local CustomParameters = {
	["Sort Method"] = "parseSortMethod",
	["Buffers"] = "parseBuffers"
}

---@enum ListParameters
local ListParameters = {
	["Output"] = true,
	["Sort Key"] = true
}

-- class

---@class TextParser
---@field text string
---@field pos integer
local TextParser = {}
TextParser.__index = TextParser

function TextParser:parse(text)
	local parsed = {{}}

	text = text:gsub("\r", "")

	self.text = text
	self.pos = 1

	self:trimQueryHeader()
	self:advancePosition(self:checkLevelPadding())
	local root = self:parseNode(1)

	parsed[1]["Plan"] = root

	return parsed
end

--#region Level 3 - Blocks

function TextParser:trimQueryHeader()
	-- quotation surround
	if string.find(self.text, "\n\"[^\n]+\"\n") then
		self.text = self.text:gsub("\"?\n\"?", "\n"):gsub("^\"", ""):gsub("\"$", "")
	end

	self.text = self.text:gsub("^%s*+?%-*+?%s*|?%s*", "")
	self.text = self.text:gsub("^Q?U?E?R?Y? ?PLAN", "")
	self.text = self.text:gsub("^%s*|?%s*+?[%s-]*+?%s*", "")
	self.text = self.text:gsub("%s*|?\n|?", "\n"):gsub("^|", "")
	self.text = self.text:gsub("%+?%-*%+?%s*$", "")
	self.text = self.text:gsub("\n(%S)", "%1")


end

function TextParser:parseNode(level)
	local node = {}

	local node_type = assert(self:parseNodeType(), "Unable to parse node type at position " .. self.pos)

	node["Node Type"] = node_type

	self:parseHeader(node)
	self:parseBody(node, level)

	return node
end

function TextParser:parseHeader(node)
	self:parseContext(node)
	self:parseCosts(node)
	self:parseAnalyze(node)

	self:parsePattern("\n")
end

function TextParser:parseBody(sink, self_level)
	local original_level = self:checkLevelPadding()

	if original_level < self_level then
		return
	end

	local level = original_level

	while level == original_level do
		self:advancePosition(level)

		if self:parsePattern("%->%s*") then
			sink["Plans"] = sink["Plans"] or {}
			sink["Plans"][#sink["Plans"]+1] = self:parseNode(level)
		elseif self:parsePattern("InitPlan%s*") then
			local name = self:parsePattern("([%w_%-.$]+)\n")
			local level = self:checkLevelPadding()
			self:advancePosition(level)

			assert(self:parsePattern("%->%s*"), "Failed to parse InitPlan")

			sink["Plans"] = sink["Plans"] or {}
			sink["Plans"][#sink["Plans"]+1] = self:parseNode(level)

			local initplan = sink["Plans"][#sink["Plans"]]
			initplan["Parent Relationship"] = "InitPlan"
			initplan["Subplan Name"] = "InitPlan " .. name
		else
			self:parseParameter(sink)
		end

		level = self:checkLevelPadding()
	end
end

--#endregion

--#region Level 2 - Constructs

function TextParser:parseContext(sink)
	local word = self:parsePattern("%s*(%w+)%s*")

	if not word then
		return
	end

	if word == "using" then
		local index_name = self:parseIdentifier()
		sink["Index Name"] = index_name

		self:parseContext(sink)
	elseif word == "on" then
		local relation_name = self:parseIdentifier()
		sink["Relation Name"] = relation_name

		self:parsePattern("\n? ")

		if string.sub(self.text, self.pos, self.pos) == " " then
			return
		end

		local alias = self:parseIdentifier()
		sink["Alias"] = alias
	else
		error("Unable to parse context at position " .. self.pos)
	end
end

function TextParser:parseCosts(sink)
	local cost = self:parsePattern("%s*%(cost=")

	if not cost then
		return
	end

	local startup_cost = self:parseUnsignedNumber()
	sink["Startup Cost"] = startup_cost

	self:advancePosition(2) -- skip ".."

	local total_cost = self:parseUnsignedNumber()
	sink["Total Cost"] = total_cost

	self:parsePattern("%s*rows=")

	local rows = self:parseUnsignedNumber()
	sink["Plan Rows"] = rows

	self:parsePattern("%s*width=")

	local width = self:parseUnsignedNumber()
	sink["Plan Width"] = width

	self:advancePosition(1) -- skip ")"
end

function TextParser:parseAnalyze(sink)
	local analyze = self:parsePattern("%s*%(actual%s*time=")

	if not analyze then
		return
	end

	local actual_startup_time = self:parseUnsignedNumber()
	sink["Actual Startup Time"] = actual_startup_time

	self:advancePosition(2) -- skip ".."

	local actual_total_time = self:parseUnsignedNumber()
	sink["Actual Total Time"] = actual_total_time

	self:parsePattern("%s*rows=")

	local rows = self:parseUnsignedNumber()
	sink["Actual Rows"] = rows

	self:parsePattern("%s*loops=")

	local loops = self:parseUnsignedNumber()
	sink["Actual Loops"] = loops

	self:advancePosition(1) -- skip ")"
end

function TextParser:parseParameter(sink)
	local parameter_name = self:parseParameterName()

	if not parameter_name then
		return
	end

	if CustomParameters[parameter_name] then
		self[CustomParameters[parameter_name]](self, sink)
	elseif ListParameters[parameter_name] then
		sink[parameter_name] = self:parseExpressionList()
		self:parseSingleCharacter("\n")
	else
		sink[parameter_name] = self:parsePattern("(.-)\n")
	end
end

function TextParser:parseExpressionList()
	local output = {}

	repeat
		local out = self:parseExpression() or self:parseIdentifier()

		local sort_collate = self:parsePattern("%s*COLLATE%s*(\"[^\"]+\")")
		out = sort_collate and (out .. " COLLATE " .. sort_collate) or out
		local sort_desc = self:parsePattern("%s*DESC")
		out = sort_desc and (out .. " DESC") or out
		local sort_nulls_first = self:parsePattern("%s*NULLS FIRST")
		out = sort_nulls_first and (out .. " NULLS FIRST") or out
		local sort_nulls_last = self:parsePattern("%s*NULLS LAST")
		out = sort_nulls_last and (out .. " NULLS LAST") or out

		if out then
			output[#output+1] = out
		end

		local comma = self:parsePattern(",%s*")
	until not comma

	return output
end

function TextParser:parseExpression()
	if self:checkSingleCharacter("'") then
		local start_pos = self.pos

		self:parseString()
		self:parsePattern("::")
		self:parseIdentifier()

		return string.sub(self.text, start_pos, self.pos - 1)
	end

	if not self:parseSingleCharacter("(") then
		return
	end

	local start_pos = self.pos
	local level = 1

	repeat
		local found = self:parsePattern(".-([()'])")

		if found == "(" then
			level = level + 1
		elseif found == ")" then
			level = level - 1
		elseif found == "'" then
			self:advancePosition(-1)
			self:parseString()
		end
	until level == 0

	if self:parseSingleCharacter(".") then
		self:parseIdentifier()
	end

	return string.sub(self.text, start_pos, self.pos - 1)
end

function TextParser:parseSortMethod(sink)
	local method, memory, disk

	method, memory = self:parsePattern("([^:]-)%s*Memory:%s*(%d+)kB\n")

	if memory then
		sink["Sort Method"] = method
		sink["Sort Space Used"] = memory
		sink["Sort Space Type"] = "Memory"
		
		return
	end
	
	method, disk = self:parsePattern("([^:]-)%s*Disk:%s*(%d+)kB\n")
	
	if disk then
		sink["Sort Method"] = method
		sink["Sort Space Used"] = disk
		sink["Sort Space Type"] = "Disk"

		return
	end

	sink["Sort Method"] = self:parsePattern("(.-)\n")
end

function TextParser:parseBuffers(sink)
	if self:parsePattern("shared") then
		local hit = self:parsePattern("%s*hit=(%d+)")
		if hit then
			sink["Shared Hit Blocks"] = hit
		end

		local read = self:parsePattern("%s*read=(%d+)")
		if read then
			sink["Shared Read Blocks"] = read
		end

		local dirtied = self:parsePattern("%s*dirtied=(%d+)")
		if dirtied then
			sink["Shared Dirtied Blocks"] = dirtied
		end

		local written = self:parsePattern("%s*written=(%d+)")
		if written then
			sink["Shared Written Blocks"] = written
		end

		self:parsePattern(",%s*")
	end

	if self:parsePattern("local") then
		local hit = self:parsePattern("%s*hit=(%d+)")
		if hit then
			sink["Local Hit Blocks"] = hit
		end

		local read = self:parsePattern("%s*read=(%d+)")
		if read then
			sink["Local Read Blocks"] = read
		end

		local dirtied = self:parsePattern("%s*dirtied=(%d+)")
		if dirtied then
			sink["Local Dirtied Blocks"] = dirtied
		end

		local written = self:parsePattern("%s*written=(%d+)")
		if written then
			sink["Local Written Blocks"] = written
		end

		self:parsePattern(",%s*")
	end

	if self:parsePattern("temp") then
		local read = self:parsePattern("%s*read=(%d+)")
		if read then
			sink["Temp Read Blocks"] = read
		end

		local written = self:parsePattern("%s*written=(%d+)")
		if written then
			sink["Temp Written Blocks"] = written
		end
	end

	self:parseSingleCharacter("\n")
end

--#endregion

--#region Level 1 - Lexems

function TextParser:parseParameterName()
	return self:parsePattern("([%w _%-/]+):%s*")
end

function TextParser:parseNodeType()
	local node_type

	local word = self:parsePattern("(%u%a*)")

	while word do
		node_type = node_type and (node_type .. " " .. word) or word

		if not self:parseSingleCharacter(" ") then
			break
		end

		word = self:parsePattern("(%u%a*)")
	end

	return node_type
end

function TextParser:parseString()
	if not self:checkSingleCharacter("'") then
		return
	end

	local str

	repeat
		local new_part = self:parsePattern("('%Z-')")

		if new_part then
			str = str and (str .. new_part) or new_part
		end
	until not new_part

	return str
end

function TextParser:parseIdentifier()
	local identifier

	if self:checkSingleCharacter("\"") then
		repeat
			local new_part = self:parsePattern("(\"%Z-\")")

			if new_part then
				identifier = identifier and (identifier .. new_part) or new_part
			end
		until not new_part
	else
		identifier = self:parsePattern("([%a_\128-\255][%w_$\128-\255]*)")
	end

	if identifier and self:parseSingleCharacter(".") then
		return identifier .. "." .. self:parseIdentifier()
	end

	return identifier
end

function TextParser:parseUnsignedNumber()
	local _, finish, left_part, dot, right_part = string.find(self.text, "^(%d+)(%.?)(%d*)", self.pos)
	if not left_part then
		return nil
	end

	self.pos = finish + 1

	return left_part .. dot .. right_part
end

--#endregion

--#region Level 0 - Basic elements

function TextParser:parseSingleCharacter(char)
	if self:checkSingleCharacter(char) then
		self.pos = self.pos + 1

		return true
	end

	return false
end

function TextParser:checkSingleCharacter(char)
	return string.sub(self.text, self.pos, self.pos) == char
end

function TextParser:checkLevelPadding()
	local _, _, level_padding = string.find(self.text, "^([ \t]*)", self.pos)

	return #level_padding
end

function TextParser:parsePattern(pattern)
	local _, finish, c1, c2, c3 = string.find(self.text, "^" .. pattern, self.pos)

	if finish then
		self.pos = finish + 1
	end

	return c1 or finish, c2, c3
end

function TextParser:advancePosition(amount)
	self.pos = self.pos + amount
end

--#endregion

function TextParser:new()
	local new_parser = {}

	setmetatable(new_parser, TextParser)

	return new_parser
end

setmetatable(TextParser, {__call = TextParser.new})

return TextParser