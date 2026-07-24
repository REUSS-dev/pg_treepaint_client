-- InfoPanel

-- config

local CACHE_SIZE = 5

---@class InfoPanel : CompositeObject
---@field CompositeObject CompositeObject
---@field font {L: love.Font, S: love.Font}
---@field titleContainer CompositeObject
---@field contentsContainer CompositeObject
---@field footerContainer CompositeObject
---@field head InfoPanelHead
---@field cacheStorage table<DiagramNode, CompositeObject[]>
---@field cacheBuckets DiagramNode[]
---@field cacheCounter integer
---@field currentNode DiagramNode?
local InfoPanel = {
	name = "InfoPanel",
	extends = "CompositeObject",
	rules = {
	},
	default = {
		w = 400,
		h = "fill",
		growth = "vertical",
		vertical = "top",
		padding = 15,
		gap = 10,

		color = COLORS.INFO_PANEL,
		font = {L = "default 24", S = "default 16"}
	},

	opaque = true
}

function InfoPanel:hide()
	self.CompositeObject.hide(self)
	self:nodeDeselect()
end

---@param node DiagramNode
function InfoPanel:nodeSelect(node)
	self:nodeDeselect()

	self.currentNode = node
	node:selectOn()
end

function InfoPanel:nodeDeselect()
	if self.currentNode then
		self.currentNode:selectOff()
		self.currentNode = nil
	end
end

---Display specific node information on info panel
---@param node DiagramNode
function InfoPanel:displayNode(node)
	local scroll = -self.contentsContainer.currentScroll

	if not self.cacheStorage[node] then
		self:createContents(node)
	end

	self:nodeSelect(node)
	self:setNodeInfo(node)

	self.contentsContainer.objects = self.cacheStorage[node]
	self.contentsContainer:relayout()
	self.contentsContainer.currentScroll = 0
	self.contentsContainer:moveScroll(scroll)

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
	self:createAnalyze(node, coverage)
	self:createBuffers(node, coverage)
	self:createWorkers(node, coverage)
	self:createOutput(node, coverage)
	self:createWAL(node, coverage)

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

	local costs = self.contentsContainer:createChild "SectionContainer" { title = "Costs Info" }
		:addText("Plan Width: " .. node.node.raw["Plan Width"] .. " bytes")
		:addText("Plan Rows: " .. node.node.raw["Plan Rows"])
		:addText("Cost: " .. node.node.startup_cost .. ".." .. node.node.total_cost)

	if node.parent.name == "DiagramVerticalContainer" and node.parent.objects[1] == node then
		costs:addText("Tree: " .. node.node.raw["Startup Cost"] .. ".." .. node.node.raw["Total Cost"], true)
	end
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createAnalyze(node, covered)
	if not node.node.raw["Actual Total Time"] then
		return
	end

	covered["Actual Startup Time"] = true
	covered["Actual Total Time"] = true
	covered["Actual Rows"] = true
	covered["Actual Loops"] = true

	local loops = node.node.raw["Actual Loops"]

	local section = self.contentsContainer:createChild "SectionContainer" { title = loops == 0 and "Timing Info (Never Executed)" or node.node.workers and "Timing Info (Parallel)" or "Timing Info", group = "info_timing" }

	if loops == 0 then
		section:addText("Never Executed")
		return
	end

	if loops == 1 then
		section
			:addText("Loops: " .. loops)
			:addTextProtected("Rows: ", node.node.rows)
			:addTextProtected("Node: ", node.node.timing.node.single[1] .. ".." .. node.node.timing.node.single[2] .. "ms")
			:addTextProtected("Tree: ", node.node.timing.tree and (node.node.timing.tree.single[1] .. ".." .. node.node.timing.tree.single[2] .. "ms") or nil, true)

		return
	end

	do
		local worker_count = node.node.workers or 1

		local node_start, node_total = string.format("%.3f", node.node.timing.node.total[1] * worker_count), string.format("%.3f", node.node.timing.node.total[2] * worker_count)
		local tree_start, tree_total

		if node.node.timing.tree then
			tree_start, tree_total = string.format("%.3f", node.node.timing.tree.total[1] * worker_count), string.format("%.3f", node.node.timing.tree.total[2] * worker_count)
		end

		section
			:addTextProtected("Workers: ", node.node.workers)
			:addText("Loops: " .. loops)
			:addTextProtected("Rows: ", node.node.rows)
			:addTextProtected("Node: ", node_start .. ".." .. node_total .. "ms")
			:addTextProtected("Tree: ", tree_total and (tree_start .. ".." .. tree_total .. "ms") or nil, true)

		section:addDivider(nil, true)
	end

	if node.node.workers then
		local worker = self:create "SectionContainer" {
			title = "Single Worker",
			group = "info_timing_worker",
			borderless = true,
			no_div = true,
			collapser_pos = "left",
		}

		worker
			:addText("Loops: " .. string.format("%g", loops / node.node.workers))
			:addTextProtected("Rows: ", math.floor(node.node.rows / node.node.workers + .5))
			:addTextProtected("Node: ", node.node.timing.node.total[1] .. ".." .. node.node.timing.node.total[2] .. "ms")
			:addTextProtected("Tree: ", node.node.timing.tree and (node.node.timing.tree.total[1] .. ".." .. node.node.timing.tree.total[2] .. "ms") or nil, true)

		section:addObject(worker)
			:addDivider(nil, true)
	end

	do
		local single = self:create "SectionContainer" {
			title = "Single Time",
			group = "info_timing_single",
			borderless = true,
			no_div = true,
			collapser_pos = "left",
		}

		single
			:addTextProtected("Rows: ", node.node.raw["Actual Rows"])
			:addTextProtected("Node: ", node.node.timing.node.single[1] .. ".." .. node.node.timing.node.single[2] .. "ms")
			:addTextProtected("Tree: ", node.node.timing.tree and (node.node.timing.tree.single[1] .. ".." .. node.node.timing.tree.single[2] .. "ms") or nil, true)

		section:addObject(single)
	end
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createBuffers(node, covered)
	if not node.node.buffers then
		return
	end

	covered["Shared Hit Blocks"] = true
	covered["Shared Read Blocks"] = true
	covered["Shared Dirtied Blocks"] = true
	covered["Shared Written Blocks"] = true
	covered["Local Hit Blocks"] = true
	covered["Local Read Blocks"] = true
	covered["Local Dirtied Blocks"] = true
	covered["Local Written Blocks"] = true
	covered["Temp Read Blocks"] = true
	covered["Temp Written Blocks"] = true

	self.contentsContainer:createChild "SectionContainer" { title = "Buffers Info" }
		:getContentsContainer()
			:createChild "BufferSheet" {
				buffers = node.node.buffers,
				font = self.font.S,
				group = "infopanel"
			}
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createWorkers(node, covered)
	if not node.node.workerDump then
		return
	end

	covered["Workers"] = true

	local workers = self.contentsContainer:createChild "SectionContainer" { title = "Workers (" .. (node.node.workers - 1) .. ")", group = "info_workers" }
		:addText("Additional workers: " .. (node.node.workers - 1))
		:addDivider(nil, true)

	local master = workers:create "SectionContainer" { title = "Master process", group = "info_workers_master", borderless = true }
	self:createWorker(node.node.workerDump[0], master)
	workers:addObject(master)

	for _, worker in ipairs(node.node.workerDump) do ---@cast worker +{no: integer}
		workers:addDivider(nil, true)
		local new_worker = workers:create "SectionContainer" { title = "Worker " .. worker.no, group = "info_workers_worker_" .. worker.no, borderless = true }
		self:createWorker(worker, new_worker)
		workers:addObject(new_worker)
	end
end

---@param worker DumpedNode
---@param section SectionContainer
function InfoPanel:createWorker(worker, section)
	---@cast worker +{no: integer, other: table<string, any>}

	if worker.loop_count then
		section
			:addText("Loops: " .. worker.loop_count)
			:addTextProtected("Rows: ", worker.rows)

		if worker.loop_count == 1 then
			section
				:addTextProtected("Node: ", worker.timing.node.single[1] .. ".." .. worker.timing.node.single[2] .. "ms")
				:addTextProtected("Tree: ", worker.timing.tree and (worker.timing.tree.single[1] .. ".." .. worker.timing.tree.single[2] .. "ms") or nil, true)
		else
			section
				:addTextProtected("Node (total): ", worker.timing.node.total[1] .. ".." .. worker.timing.node.total[2] .. "ms")
				:addTextProtected("Node (single time): ", worker.timing.node.single[1] .. ".." .. worker.timing.node.single[2] .. "ms")
				:addTextProtected("Tree (total): ", worker.timing.tree and (worker.timing.tree.total[1] .. ".." .. worker.timing.tree.total[2] .. "ms") or nil, true)
				:addTextProtected("Tree (single time): ", worker.timing.tree and (worker.timing.tree.single[1] .. ".." .. worker.timing.tree.single[2] .. "ms") or nil, true)
		end
	end

	if worker.buffers then
		local buffer_group = "info_workers_buffers_worker_" .. (worker.no or "master")

		local buffer_section = self:create "SectionContainer" { title = "Buffers", borderless = true, no_div = true, group = buffer_group, collapser_pos = "left"}

		local buffers = self:create "BufferSheet" {
			buffers = worker.buffers,
			group = buffer_group
		}
		buffer_section:addObject(buffers)

		section:addObject(buffer_section)
	end

	if (not worker.wal or worker.wal.node.records == 0) and not worker.other then
		return
	end

	local other_group = "info_workers_other_worker_" .. (worker.no or "master")

	local other_section = self:create "SectionContainer" { title = "Other", borderless = true, no_div = true, group = other_group, collapser_pos = "left"}

	if worker.wal and (worker.wal.node.records ~= 0 or worker.other) then
		if worker.wal.node.records == 0 then
			other_section:addText("No WAL Records created.")
		else
			if worker.wal.node.bytes and worker.wal.node.bytes > 0 then
				other_section:addText("Records: " .. worker.wal.node.records .. " (" .. worker.wal.node.bytes .. " bytes)")
			else
				other_section:addTextProtected("Records: ", worker.wal.node.records)
			end

			if worker.wal.node.fpi_bytes and worker.wal.node.fpi_bytes > 0 then
				other_section:addText("FPI: " .. worker.wal.node.fpi .. " (" .. worker.wal.node.fpi_bytes .. " bytes)")
			else
				other_section:addTextProtected("FPI: ", worker.wal.node.fpi)
			end

			other_section:addTextProtected("Buffers Full: ", worker.wal.node.buffers_full)
		end
	end

	if worker.other then
		if worker.wal then
			other_section:addDivider(nil, true)
		end

		for key, value in pairs(worker.other) do
			other_section:addText(key .. ": " .. value)
		end
	end

	section:addObject(other_section)
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createOutput(node, covered)
	if not node.node.raw["Output"] then
		return
	end

	covered["Output"] = true

	local wal = self.contentsContainer:createChild "SectionContainer" { title = "Output Info" }
		:addText("Output count: " .. #node.node.raw["Output"])
		:addTextProtected("", #node.node.raw["Output"] > 0 and "" or nil)

	for _, value in ipairs(node.node.raw["Output"]) do
		wal:addText(value)
	end
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createWAL(node, covered)
	if not node.node.wal then
		return
	end

	covered["WAL Records"] = true
	covered["WAL Bytes"] = true
	covered["WAL FPI"] = true
	covered["WAL FPI Bytes"] = true
	covered["WAL Buffers Full"] = true

	local wal = self.contentsContainer:createChild "SectionContainer" { title = node.node.wal.node.records == 0 and "WAL Info (None)" or node.node.wal.tree and "WAL Info (Tree)" or "WAL Info (Node)", group = "info_wal" }

	local wal_main = node.node.wal.tree or node.node.wal.node

	if wal_main.records == 0 then
		wal:addText("No WAL Records created.")
		return
	end

	if wal_main.bytes and wal_main.bytes > 0 then
		wal:addText("Records: " .. wal_main.records .. " (" .. wal_main.bytes .. " bytes)")
	else
		wal:addTextProtected("Records: ", wal_main.records)
	end

	if wal_main.fpi_bytes and wal_main.fpi_bytes > 0 then
		wal:addText("FPI: " .. wal_main.fpi .. " (" .. wal_main.fpi_bytes .. " bytes)")
	else
		wal:addTextProtected("FPI: ", wal_main.fpi)
	end

	wal:addTextProtected("Buffers Full: ", wal_main.buffers_full)

	if not node.node.wal.tree then
		return
	end

	do
		if node.node.wal.node.records == 0 then
			wal:addText("\nNo WAL Records created by Node.")
			return
		end

		local node_wal = self:create "SectionContainer" {
			title = "Node",
			group = "info_wal_node",
			borderless = true,
			no_div = true,
		}

		if node.node.wal.node.bytes and node.node.wal.node.bytes > 0 then
			node_wal:addText("Records: " .. node.node.wal.node.records .. " (" .. node.node.wal.node.bytes .. " bytes)")
		else
			node_wal:addTextProtected("Records: ", node.node.wal.node.records)
		end

		if node.node.wal.node.fpi_bytes and node.node.wal.node.fpi_bytes > 0 then
			node_wal:addText("FPI: " .. node.node.wal.node.fpi .. " (" .. node.node.wal.node.fpi_bytes .. " bytes)")
		else
			node_wal:addTextProtected("FPI: ", node.node.wal.node.fpi)
		end

		node_wal:addTextProtected("Buffers Full: ", node.node.wal.node.buffers_full)

		wal
			:addDivider(nil, true)
			:addObject(node_wal)
	end
end

---@param node DiagramNode
---@param covered table<string, boolean>
function InfoPanel:createUnknown(node, covered)
	local unknown

	for k, v in pairs(node.node.raw) do
		if not covered[k] then
			unknown = unknown or self.contentsContainer:createChild "SectionContainer" { title = "Other" }

			unknown:addText(k .. ": " .. tostring(v))
		end
	end
end

function InfoPanel:new()
	self.cacheStorage = {}
	self.cacheBuckets = {}
	self.cacheCounter = 0

	-- Head
	self.head = self:createChild "InfoPanelHead" {
		font = {title = self.font.L, text = self.font.S}
	}

	self.contentsContainer = self:createChild "Container" { gap = 10, horizontal = "left", vertical = "top", w = "fill", h = "fill", shear = true, scroll = true, hover = true }
	self.footerContainer = self:createChild "Container" { gap = 2, horizontal = "left", w = "fill" }

	self:hide()
end

return InfoPanel