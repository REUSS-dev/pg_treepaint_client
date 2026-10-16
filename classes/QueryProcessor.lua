-- QueryProcessor

local NodeStringParser = require("classes.NodeStringParser")

-- docs

---@alias Query ProcessedStrucutre

---@alias ProcessedStrucutre {name: string?, type: string, children: ProcessedStrucutre[]?, properties: table<string, any>}
---@alias ProcessedList {name: string?, children: (ProcessedStrucutre|ProcessedList)[]?}

---@class QueryProcessor
---@field parser NodeStringParser
local QueryProcessor = {}
QueryProcessor.__index = QueryProcessor

---@param query string|RawQuery
---@return Query
function QueryProcessor:process(query)
    if type(query) == "string" then
        query = self.parser:parse(query)
    end

    return self:processStructure(query)
end

function QueryProcessor:processStructure(raw, name)
    local processed = {
        name = name,
        children = {},
        properties = {},
    }

    for key, value in pairs(raw) do
        if key == "__name" then
            processed.type = value
        elseif type(value) == "table" then
            if value.__name then
                processed.children[#processed.children+1] = self:processStructure(value, key)
            elseif value.items and not value.type then
                local processed_list = self:processList(value, key)
                if processed_list then
                    processed.children[#processed.children+1] = processed_list
                else
                    processed.properties[key] = value
                end
            end
        else
            processed.properties[key] = value
        end
    end

    if #processed.children == 0 then
        processed.children = nil
    end

    if processed.children then
        table.sort(processed.children, function(lower, higher)
            return lower.name < higher.name
        end)
    end

    return processed
end

---@param raw QueryList
---@param name string?
---@return ProcessedList?
function QueryProcessor:processList(raw, name)
    local processed = {
        name = name,
        type = name .. "_list"
    }

    if #raw.items == 0 then
        return processed
    end

    processed.children = {}

    for i, value in ipairs(raw.items) do
        if type(value) == "table" then
            if value.__name then
                processed.children[i] = self:processStructure(value)
            elseif value.items and not value.type then
                processed.children[i] = self:processList(value, "List")
            else
                return nil
            end
        else
            return nil
        end
    end

    return processed
end

function QueryProcessor:new()
	local new_processor = {
        parser = NodeStringParser()
    }

	setmetatable(new_processor, QueryProcessor)

	return new_processor
end

setmetatable(QueryProcessor, {__call = QueryProcessor.new})

return QueryProcessor