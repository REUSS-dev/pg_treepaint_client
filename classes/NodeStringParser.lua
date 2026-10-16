-- NodeStringParser

---@alias RawQuery QueryStructure

---@alias QueryValue QueryStructure|QueryList|QueryString|QueryNumber|QueryBoolean|QueryNull|QueryDatum

---@alias QueryStructure {__name: string, [string]: QueryValue}
---@alias QueryList {type: "b"|"i"|nil, items: any[]}
---@alias QueryDatum {size: integer, data: integer[]}
---@alias QueryString string
---@alias QueryNumber number
---@alias QueryBoolean boolean
---@alias QueryNull {[1]: "null"}

-- consts

local NULL = {"null"}

---@class NodeStringParser
---@field text string
---@field pos integer
local NodeStringParser = {}
NodeStringParser.__index = NodeStringParser

---Parse Query structure
---@param node_string string
---@return RawQuery
function NodeStringParser:parse(node_string)
	self.text = node_string
	self.pos = 1

	return self:parseValue() --[[@as table]]
end

---@return QueryValue?
function NodeStringParser:parseValue()
	local char = self:readChar()

	if char == "{" then
		return self:parseObject()
	elseif char == "(" then
		return self:parseList()
	elseif tonumber(char) then
		return self:parseNumber()
	elseif char == "<" then
		return self:parseNull()
	elseif char == "t" then
		if self:parseTrue() then
			return true
		end

		return self:parseIdentifier()
	elseif char == "f" then
		if self:parseFalse() then
			return false
		end

		return self:parseIdentifier()
	elseif char == "\"" then
		return self:parseString()
	else
		return self:parseIdentifier()
	end
end

---@return QueryStructure
function NodeStringParser:parseObject()
	local new_object = {}

	self:parseChar("{", true)

	local object_name = self:parseObjectName()
	new_object.__name = object_name

	local field_name = self:parseFieldName()

	while field_name do
		local value = self:parseValue()
		self:parseSpace()

		new_object[field_name] = value

		field_name = self:parseFieldName()
	end

	self:parseChar("}", true)

	return new_object
end

function NodeStringParser:parseObjectName()
	return self:parsePattern("([%u_][%u%d_]*)%s")
end

function NodeStringParser:parseFieldName()
	if not self:parseChar(":") then
		return nil
	end

	local field_name = self:parsePattern("([%a_][%w_]*)%s")

	return field_name
end

---@return QueryList
function NodeStringParser:parseList()
	local new_list = {
		items = {}
	}

	self:parseChar("(", true)

	if self:parseChar("b") then
		new_list.type = "b"
		self:parseSpace()
	elseif self:parseChar("i") then
		new_list.type = "i"
		self:parseSpace()
	end

	local closing = self:parseChar(")")

	while not closing do
		local value = self:parseValue()
		new_list.items[#new_list.items+1] = value

		self:parseSpace()

		closing = self:parseChar(")")
	end

	return new_list
end

---@return QueryString
function NodeStringParser:parseString()
	self:parseChar("\"")

	local str = self:parseIdentifier()

	self:parseChar("\"")

	return str
end

---@return (QueryNumber|QueryDatum)?
function NodeStringParser:parseNumber()
	local _, finish, minus, left_part, dot, right_part = string.find(self.text, "^(%-?)(%d+)(%.?)(%d*)", self.pos)
	if not left_part then
		return nil
	end ---@cast left_part integer

	self.pos = finish + 1

	self:parseSpace()

	if self:readChar() == "[" then
		return self:parseDatum(tonumber(left_part) --[[@as integer]])
	end

	return tonumber(minus .. left_part .. dot .. right_part) --[[@as number]]
end

---@param length integer
---@return QueryDatum
function NodeStringParser:parseDatum(length)
	local new_datum = { length = length, data = {} }

	self:parseChar("[")
	self:parseSpace()

	local new_byte = self:parseNumber()

	while new_byte do
		if new_byte < 0 then
			new_byte = 256 + new_byte
		end

		new_datum.data[#new_datum.data+1] = new_byte

		self:parseSpace()
		new_byte = self:parseNumber()
	end

	self:parseChar("]")

	return new_datum
end

---@return QueryNull
function NodeStringParser:parseNull()
	self:parseChar("<", true)
	self:parseChar(">", true)

	return NULL
end

---@return boolean
function NodeStringParser:parseTrue()
	return self:parsePattern("true") ~= nil
end

---@return boolean
function NodeStringParser:parseFalse()
	return self:parsePattern("false") ~= nil
end

---@return QueryString
function NodeStringParser:parseIdentifier()
	local identifier

	repeat
		local new_part, interest = self:parsePattern("(.-)([\\}) \"])") --[[@as string?]]	---@type string?, string?

		if new_part then
			identifier = identifier and (identifier .. new_part) or new_part

			if interest == " " or interest == "}" or interest == ")" then
				if interest ~= " " then
					self.pos = self.pos - 1
				end

				new_part = nil
			elseif interest == "\"" then
				if self:readChar() == " " then
					self.pos = self.pos - 1
					new_part = nil
				else
					identifier = identifier .. "\""
				end
			else
				local char = self:readChar()

				if string.match(char, "%l") then
					identifier = identifier .. "\\" .. char
				else
					identifier = identifier .. char
				end

				self.pos = self.pos + 1
			end
		end
	until not new_part

	return identifier
end

function NodeStringParser:parsePattern(pattern)
	local _, finish, c1, c2, c3 = string.find(self.text, "^" .. pattern, self.pos)

	if finish then
		self.pos = finish + 1
	end

	return c1 or finish, c2, c3
end

function NodeStringParser:parseSpace()
	return self:parseChar(" ")
end

function NodeStringParser:parseChar(char, raise_error)
	if self:readChar() ~= char then
		if raise_error then
			error("Character \"" .. char .. "\" (" .. string.byte(char) .. ") expected at pos " .. self.pos .. " got character \"" .. self:readChar() .. "\" (" .. string.byte(self:readChar()) .. ") instead.")
		end

		return nil
	end

	self.pos = self.pos + 1

	return char
end

function NodeStringParser:readChar()
	return string.sub(self.text, self.pos, self.pos)
end

function NodeStringParser:new()
	local new_parser = {}

	setmetatable(new_parser, NodeStringParser)

	return new_parser
end

setmetatable(NodeStringParser, {__call = NodeStringParser.new})

return NodeStringParser