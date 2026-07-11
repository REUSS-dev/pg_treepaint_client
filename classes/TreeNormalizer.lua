-- TreeNormalizer

---@class TreeNormalizer
---@field text string
local TreeNormalizer = {}
TreeNormalizer.__index = TreeNormalizer

function TreeNormalizer:normalize(text)
	self.text = text

	self:normalizeNewlines()
	self:normalizeDoubleQuotation()

	return self.text
end

function TreeNormalizer:normalizeNewlines()
	self.text = string.gsub(self.text, "\r", "")
	self.text = string.gsub(self.text, "%s*%+\n", "\n")
end

function TreeNormalizer:normalizeDoubleQuotation()
	local beg, fin = 1, #self.text

	local _, f, first_nonspace = self:findNonSpace()
	if first_nonspace == "\"" then
		beg = f + 1
	end

	local s, _, last_nonspace = self:findPattern("(%S)%s*$")
	if last_nonspace == "\"" then
		fin = s - 1
	end

	if beg ~= 1 or fin ~= #self.text then
		self.text = string.sub(self.text, beg, fin)
	end

	if self:findPattern("\"\"") and not self:findPattern("[^\"]\"[^\"]") then
		self.text = string.gsub(self.text, "\"\"", "\"")
	end
end

function TreeNormalizer:findNonSpace(pos)
	return self:findPattern("(%S)", pos)
end

function TreeNormalizer:findPattern(pattern, pos)
	pos = pos or 1
	return string.find(self.text, pattern, pos)
end

function TreeNormalizer:new()
	local new_filter = {}

	setmetatable(new_filter, TreeNormalizer)

	return new_filter
end

setmetatable(TreeNormalizer, {__call = TreeNormalizer.new})

return TreeNormalizer