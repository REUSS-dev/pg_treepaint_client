-- node

---@class QueryNodeRANGETBLENTRY_relation : QueryNodeRANGETBLENTRY
---@field QueryNodeRANGETBLENTRY QueryNodeRANGETBLENTRY
local QueryNodeRANGETBLENTRY_relation = {
	name = "QueryNodeRANGETBLENTRY_relation",
	extends = "QueryNodeRANGETBLENTRY",
	default = {
		colors = {
			border = COLORS.NODE_QUERY_RTE_RELATION
		}
	}
}

function QueryNodeRANGETBLENTRY_relation:populateInfo(covered)
    covered["relkind"] = true
    covered["relid"] = true
    covered["inh"] = true
    covered["rellockmode"] = true
    covered["tablesample"] = true

    local sections = self.QueryNodeRANGETBLENTRY.populateInfo(self, covered)

    local section = self:create "SectionContainer" { title = "query.RTE.relation.section.title", collapsible = false }

    local locale = self:getObjectClass("Label").locale

    local relkind = self.query.properties["relkind"]
    if relkind then
        local relkind_string = locale:rawget("query.relkind." .. relkind) or relkind
        section:addTextParametrized("query.RTE.relation.section.relkind", relkind_string)
    end

    section:addTextParametrized("query.RTE.relation.section.relid", self.query.properties["relid"])

    if self.query.properties["inh"] ~= nil then
        if self.query.properties["inh"] then
            section:addText("query.RTE.relation.section.inh_true")
        else
            section:addText("query.RTE.relation.section.inh_false")
        end
    end

    local rellockmode = self.query.properties["rellockmode"]
    if rellockmode then
        local rellockmode_string = locale:rawget("query.rellockmode." .. rellockmode) or rellockmode
        section:addTextParametrized("query.RTE.relation.section.rellockmode", rellockmode_string)
    end

    if self.query.properties["tablesample"] ~= nil then
        if self.query.properties["tablesample"][1] ~= "null" then
            section:addTextParametrized("query.RTE.relation.section.tablesample", tostring(self.query.properties["tablesample"]))
        else
            section:addText("query.RTE.relation.section.tablesample_null", true)
        end
    end

    sections[#sections+1] = section

	return sections
end

-- node fnc

function QueryNodeRANGETBLENTRY_relation:new()
    local locale = self:getObjectClass("Label").locale

    -- title
    if self.title_subtype then
        local relkind = self.query.properties["relkind"]
        if relkind then
            local relkind_string = locale:rawget("query.relkind." .. relkind) or relkind
            if self.query.calculated["alias"] then
                relkind_string = relkind_string .. " (" .. self.query.calculated["alias"] .. ")"
            end
            self.title_subtype:setText(relkind_string)
        else
            self.titleContainer:remove(self.title_subtype)
            self.title_subtype = nil
        end
    end

    local name_label = self.titleContainer.objects[1] --[[@as Label]]
    name_label:setText("query.RTE.relation.title", {self.query.index or "?"})
end

return QueryNodeRANGETBLENTRY_relation