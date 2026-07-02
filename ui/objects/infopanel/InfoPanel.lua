-- InfoPanel

-- config

local CACHE_SIZE = 5

---@class InfoPanel : CompositeObject
---@field font string
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field head InfoPanelHead
---@field cacheStorage table<DiagramNode, CompositeObject[]>
---@field cacheBuckets DiagramNode[]
---@field cacheCounter integer
local InfoPanel = {
	name = "InfoPanel",
	extends = "CompositeObject",
	rules = {
		{{"font"}, "font"}
	},
	default = {
		w = 400,
		h = "fill",
		growth = "vertical",
		vertical = "top",
		padding = 15,
		gap = 10,

		color = COLORS.INFO_PANEL
	},

	opaque = true
}

---Display specific node information on info panel
---@param node DiagramNode
function InfoPanel:displayNode(node)
	if not self.cacheStorage[node] then
		self:createContents(node)
	end

	self:setNodeInfo(node)
	self.contentsContainer.objects = self.cacheStorage[node]
	self.contentsContainer:relayout()

	self:show()
end

---@param node DiagramNode
function InfoPanel:setNodeInfo(node)
	self.head:setNode(node)
end

---@param node DiagramNode
function InfoPanel:createContents(node)
	local bucket = self.cacheCounter % CACHE_SIZE
	local objects = {}
	local coverage = {
		["Node Type"] = true,
		["Plans"] = true
	}

	if self.cacheBuckets[bucket] then
		self.cacheStorage[self.cacheBuckets[bucket]] = nil
	end

	self.cacheBuckets[bucket] = node
	self.cacheStorage[node] = objects
	self.contentsContainer.objects = objects

	self:createNodeSpecific(objects, node, coverage)
	self:createCosts(node, coverage)

	self:createUnknown(node, coverage)

	self.cacheCounter = self.cacheCounter + 1
end

---Generates node-specific section of info panel body
---@param storage ObjectUI[]
---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createNodeSpecific(storage, node, covered)
	local node_specifics = node:populateInfo(covered)

	if node_specifics.name then
		node_specifics.parent = self.contentsContainer
		storage[#storage+1] = node_specifics

		return
	end

	for _, object in ipairs(node_specifics) do
		object.parent = self.contentsContainer
		storage[#storage+1] = object
	end
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createCosts(node, covered)
	if not node.node.raw["Total Cost"] then
		return
	end

	covered["Startup Cost"] = true
	covered["Total Cost"] = true
	covered["Plan Rows"] = true
	covered["Plan Width"] = true

	self.contentsContainer:createChild "InfoPanelSection" { title = "Costs Info" }
		:addText("Node: " .. node.node.startup_cost .. " .. " .. node.node.total_cost)
		:addText("Tree: " .. node.node.raw["Startup Cost"] .. " .. " .. node.node.raw["Total Cost"])
		:addText("Plan Rows: " .. node.node.raw["Plan Rows"])
		:addText("Plan Width: " .. node.node.raw["Plan Width"])
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createUnknown(node, covered)
	local unknown

	for k, v in pairs(node.node.raw) do
		if not covered[k] then
			unknown = unknown or self.contentsContainer:createChild "InfoPanelSection" { title = "Other" }

			unknown:addText(k .. ": " .. tostring(v))
		end
	end
end

function InfoPanel:new()
	self.cacheStorage = {}
	self.cacheBuckets = {}
	self.cacheCounter = 0

	self:getObjectClass("InfoPanelSection").font = self.font

	-- Head
	self.head = self:createChild "InfoPanelHead" {
		font = self.font
	}

	self.contentsContainer = self:createChild "Container" { gap = 10, horizontal = "left", vertical = "top", w = "fill", h = "fill", shear = true, scroll = true, hover = true }
	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self:hide()
end

return InfoPanel