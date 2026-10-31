-- QueryProcessor

local NodeStringParser = require("classes.NodeStringParser")

-- docs

---@alias Query ProcessedStructure

---@alias ProcessedStructure {name: string?, type: string, subtype: string?, children: ProcessedStructure[]?, properties: table<string, any>}
---@alias ProcessedList {name: string?, children: (ProcessedStructure|ProcessedList)[]?}

-- consts

local RTE_KIND = {
    [0] = "relation",
    "subquery",
    "join",
    "function",
    "tablefunc",
    "values",
    "cte",
    "namedtuplestore",
    "result"
}

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

---@param raw QueryStructure
---@param name string?
---@return ProcessedStructure
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
            if value.__name then ---@cast value QueryStructure
                processed.children[#processed.children+1] = self:processStructure(value, key)
            elseif value.items and not value.type then ---@cast value QueryList
                local processed_list = self:processList(value, key)
                if processed_list then
                    processed.children[#processed.children+1] = processed_list
                else
                    processed.properties[key] = value
                end
            else
                processed.properties[key] = value
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

    if raw.__name == "RANGETBLENTRY" then
        self:processRTE(processed, raw)
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

---@param processed ProcessedStructure
---@param raw QueryStructure
---@return ProcessedStructure
function QueryProcessor:processRTE(processed, raw)
    local rte_kind = raw["rtekind"]

    if not rte_kind then
        return processed
    end

    processed.subtype = RTE_KIND[rte_kind] or rte_kind

    if rte_kind == 0 then
        if raw["relkind"] == 'P' then
            processed.properties["relkind"] = 'p'
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