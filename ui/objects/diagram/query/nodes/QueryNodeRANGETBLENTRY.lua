-- node

---@class QueryNodeRANGETBLENTRY : QueryNode
---@field QueryNode QueryNode
---@field title_subtype Label?
local QueryNodeRANGETBLENTRY = {
	name = "QueryNodeRANGETBLENTRY",
	extends = "QueryNode",
	default = {
		colors = {
			border = COLORS.NODE_QUERY_RTE
		}
	}
}

function QueryNodeRANGETBLENTRY:populateInfo(covered)
    covered["rtekind"] = true
    covered["alias"] = true
    covered["inFromCl"] = true
    covered["securityQuals"] = true
	covered["perminfoindex"] = true

	local locale = self:getObjectClass("Label").locale
	local sections = {}

	local calculated = self.query.calculated
	local props = self.query.properties

	--#region alias section

	if calculated.alias then
		local alias_section = self:create "SectionContainer" { title = "query.RTE.section_alias.title", collapsible = false}

		alias_section:addTextParametrized("query.RTE.section_alias.alias", calculated.alias)

		if calculated.alias_columns and #calculated.alias_columns > 0 then
			local columns_title = locale:format("query.RTE.section_alias.colnames_title", {#calculated.alias_columns})

			local columns = self:create "SectionContainer" { title = columns_title, borderless = true}

			for i, column in ipairs(calculated.alias_columns) do
				columns:addTextParametrized("query.RTE.section_alias.colname", {i, column})
			end

			alias_section:addDivider(nil, true)
			alias_section:addObject(columns)
		end

		sections[#sections+1] = alias_section
	end

	--#endregion

	--#region eref section

	if calculated.eref then
		local alias_section = self:create "SectionContainer" { title = "query.RTE.section_eref.title"}

		alias_section:addTextParametrized("query.RTE.section_eref.eref", calculated.eref)

		if calculated.eref_columns and #calculated.eref_columns > 0 then
			local columns_title = locale:format("query.RTE.section_eref.colnames_title", {#calculated.eref_columns})

			local columns = self:create "SectionContainer" { title = columns_title, borderless = true}

			for i, column in ipairs(calculated.eref_columns) do
				columns:addTextParametrized("query.RTE.section_eref.colname", {i, column})
			end

			alias_section:addDivider(nil, true)
			alias_section:addObject(columns)
		end

		sections[#sections+1] = alias_section
	end

	--#endregion

	--#region Main section

	local section_title = locale:format("query.RTE.section.title", {self.query.index or "?"})
	local section = self:create "SectionContainer" {title = section_title}

	if props["inFromCl"] ~= nil then
        if props["inFromCl"] then
            section:addText("query.RTE.section.infromcl_true")
        else
            section:addText("query.RTE.section.infromcl_false")
        end
    end

	if not covered["inh"] and props["inh"] ~= nil then
		section:addTextParametrized("query.RTE.section.inh", tostring(props["inh"]))
		covered["inh"] = true
	end

	if not covered["lateral"] and props["lateral"] ~= nil then
		if props["lateral"] then
            section:addText("query.RTE.section.lateral_true")
        else
            section:addText("query.RTE.section.lateral_false", true)
        end
		covered["lateral"] = true
	end

	if props["securityQuals"] ~= nil then
        if props["securityQuals"][1] ~= "null" then
            section:addTextParametrized("query.RTE.section.securityquals", tostring(props["securityQuals"]))
        else
            section:addText("query.RTE.section.securityquals_null", true)
        end
    end

	sections[#sections+1] = section

	--#endregion

	--#region Permissions section

	local perminfoindex = props["perminfoindex"]
	if perminfoindex then
		local permission_section = self:create "SectionContainer" { title = perminfoindex == 0 and "query.RTE.section_permissions.title_no" or "query.RTE.section_permissions.title" }

		permission_section:addTextParametrized("query.RTE.section_permissions.index", perminfoindex)

		permission_section:addDivider({0, 5, 0, 5}, true)

		if perminfoindex == 0 then
			permission_section:addText("query.RTE.section_permissions.no_check")
		else
			local infonodes = self:getPermInfoNodes()
			local perminfo = infonodes and infonodes[perminfoindex]

			if perminfo then
				local goto_button = self:create "Button" {
					text = "query.RTE.section_permissions.jump",
					font = "default 16",
					color = COLORS.PERMISSIONS_JUMP_BUTTON,
					textColor = COLORS.COLOR_TEXT_1,
					additionalColor = COLORS.PERMISSIONS_JUMP_BUTTON_BORDER,
					w = "hug",
					h = "hug",
					r = 12,
					growth = "horizontal",
					gap = 10,
					action = function ()
						self.diagram:jumpFocusNode(perminfo)
					end
				}

				goto_button:createChild "Icon" {
					w = 22,
					h = 22,
					style = "ArrowRight",
					color = perminfo.palette:getColorByIndex(3)
				}

				permission_section:addObject(goto_button)
			else
				permission_section:addText("query.RTE.section_permissions.jump_fail")
			end
		end

		sections[#sections+1] = permission_section
	end

	--#endregion

	return sections
end

function QueryNodeRANGETBLENTRY:getPermInfoNodes()
	local rtable_list = self:getParentNode()

	if rtable_list then
		local query = rtable_list:getParentNode()
		if query then
			local query_children = query:getChildrenNodes() --[[@as DiagramNode[]?]]

			if query_children then
				for _, child in ipairs(query_children) do ---@cast child QueryNode
					if child.query.name == "rteperminfos" then
						return child:getChildrenNodes()
					end
				end
			end
		end
	end
end

-- node fnc

function QueryNodeRANGETBLENTRY:new()
	if self.query.index then
		local name_label = self.titleContainer.objects[1] --[[@as Label]]
    	name_label:setText("query.RTE.title", {tostring(self.query.index)})
	end

	self.title_subtype = self.titleContainer:createChild "Label" {
		w = "fill",
		font = self.font.M,
		horizontal = "left",
		text = tostring(self.query.subtype),
		textColor = self.text_color_desc,
		no_locale = true,
	}
end

return QueryNodeRANGETBLENTRY