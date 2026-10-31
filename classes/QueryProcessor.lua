-- QueryProcessor

local NodeStringParser = require("classes.NodeStringParser")

-- docs

---@alias Query ProcessedStructure

---@alias ProcessedStructure {name: string?, index: integer?, type: string, subtype: string?, children: ProcessedStructure[]?, properties: table<string, any>, calculated: table<string, any>}
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
---@param name string|integer?
---@return ProcessedStructure
function QueryProcessor:processStructure(raw, name)
    local processed = {
        children = {},
        properties = {},
        calculated = {}
    }

    if name then
        if type(name) == "number" then
            processed.index = name
        else
            processed.name = name
        end
    end

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

    if raw.__name == "RANGETBLENTRY" then
        self:processRTE(processed, raw)
    end

    if #processed.children == 0 then
        processed.children = nil
    else
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
                processed.children[i] = self:processStructure(value, i)
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

    -- Demote alias ALIAS structure to a field in calculated
    local alias_i, alias

    for i, child in ipairs(processed.children) do
        if child.name == "alias" then
            alias_i = i
            alias = child
            break
        end
    end

    if alias then
        -- Ensure this is a plain ALIAS structure
        if alias.type == "ALIAS" then
            local clean = true
            local namealias, columns

            for _, _ in pairs(alias.children or {}) do
                clean = false
                break
            end

            for key, value in pairs(clean and alias.properties or {}) do
                if key == "aliasname" then
                    namealias = value
                elseif key == "colnames" then
                    if value[1] ~= "null" then ---@cast value QueryList
                        columns = value.items or {}
                    end
                else
                    clean = false
                    break
                end
            end

            processed.calculated["alias"] = namealias
            processed.calculated["alias_columns"] = columns

            if clean then
                table.remove(processed.children, alias_i)
            end
        end
    end

    -- Demote eref ALIAS structure to a field in calculated
    local eref_i, eref

    for i, child in ipairs(processed.children) do
        if child.name == "eref" then
            eref_i = i
            eref = child
            break
        end
    end

    if eref then
        -- Ensure this is a plain ALIAS structure
        if eref.type == "ALIAS" then
            local clean = true
            local nameref, columns

            for _, _ in pairs(eref.children or {}) do
                clean = false
                break
            end

            for key, value in pairs(clean and eref.properties or {}) do
                if key == "aliasname" then
                    nameref = value
                elseif key == "colnames" then
                    if value[1] ~= "null" then ---@cast value QueryList
                        columns = value.items or {}
                    end
                else
                    clean = false
                    break
                end
            end

            processed.calculated["eref"] = nameref
            processed.calculated["eref_columns"] = columns

            if clean then
                table.remove(processed.children, eref_i)
            end
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