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
	self:createFilters(node, coverage)
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
function InfoPanel:createFilters(node, covered)
	local filter, filter_rows = node.node.raw["Filter"], node.node.raw["Rows Removed by Filter"]
	local join_filter, join_filter_rows = node.node.raw["Join Filter"], node.node.raw["Rows Removed by Join Filter"]
	local index_filter, index_filter_rows = node.node.raw["Index Cond"], node.node.raw["Rows Removed by Index Recheck"]
	local bitmap_filter = node.node.raw["Recheck Cond"]

	if not (
		filter or
		filter_rows or
		join_filter or
		join_filter_rows or
		index_filter or
		index_filter_rows or
		bitmap_filter
	) then
		return
	end

	covered["Rows Removed by Filter"] = true
	covered["Filter"] = true
	covered["Rows Removed by Join Filter"] = true
	covered["Join Filter"] = true
	covered["Rows Removed by Index Recheck"] = true
	covered["Index Cond"] = true
	covered["Recheck Cond"] = true

	local total_filtered = (filter_rows or 0) + (join_filter_rows or 0) + (index_filter_rows or 0)

	local section = self.contentsContainer:createChild "SectionContainer" {
		title = "info.filters.title",
		group = "info_filters",
	}

	section:addTextParametrized("info.filters.total_rows", total_filtered)

	if filter or filter_rows then
		section:addDivider(nil, true)
		section:addTextParametrized("info.filters.filter_rows", filter_rows)
		section:addTextParametrized("info.filters.filter", filter)
	end

	if join_filter or join_filter_rows then
		section:addDivider(nil, true)
		section:addTextParametrized("info.filters.join_filter_rows", join_filter_rows)
		section:addTextParametrized("info.filters.join_filter", join_filter)
	end

	if index_filter or index_filter_rows or bitmap_filter then
		section:addDivider(nil, true)
		section:addTextParametrized("info.filters.index_filter_rows", index_filter_rows)
		section:addTextParametrized("info.filters.index_filter", index_filter)
		section:addTextParametrized("info.filters.bitmap_filter", bitmap_filter)
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

	local costs = self.contentsContainer:createChild "SectionContainer" { title = "info.costs.title" }
		:addTextParametrized("info.costs.rows", node.node.raw["Plan Rows"])
		:addTextParametrized("info.costs.width", node.node.raw["Plan Width"])
		:addTextParametrized("info.costs.cost", {startup = node.node.startup_cost, total = node.node.total_cost})

	if node.parent.name == "DiagramVerticalContainer" and node.parent.objects[1] == node then
		costs:addTextParametrized("info.costs.tree", {startup = node.node.raw["Startup Cost"], total = node.node.raw["Total Cost"]}, true)
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

	local section = self.contentsContainer:createChild "SectionContainer" { title = loops == 0 and "info.analyze.title_never_executed" or node.node.workers and "info.analyze.title_parallel" or "info.analyze.title", group = "info_timing" }

	if loops == 0 then
		section:addText("info.analyze.never_executed")
		return
	end

	if loops == 1 then
		section
			:addTextParametrized("info.analyze.loops", loops)
			:addTextParametrized("info.analyze.rows", node.node.rows)
			:addTextParametrized("info.analyze.node", {startup = node.node.timing.node.single[1], total = node.node.timing.node.single[2]})
			:addTextParametrized("info.analyze.tree", node.node.timing.tree and {startup = node.node.timing.tree.single[1], total = node.node.timing.tree.single[2]}, true)

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
			:addTextParametrized("info.analyze.workers", node.node.workers)
			:addTextParametrized("info.analyze.loops", loops)
			:addTextParametrized("info.analyze.rows", node.node.rows)
			:addTextParametrized("info.analyze.node", {startup = node_start, total = node_total})
			:addTextParametrized("info.analyze.tree", tree_total and {startup = tree_start, total = tree_total}, true)

	end

	section:addDivider(nil, true)

	if node.node.workers then
		local worker = self:create "SectionContainer" {
			title = "info.analyze.heading_worker",
			group = "info_timing_worker",
			borderless = true,
			no_div = true,
			collapser_pos = "left",
		}

		worker
			:addTextParametrized("info.analyze.loops", string.format("%g", loops / node.node.workers))
			:addTextParametrized("info.analyze.rows", math.floor(node.node.rows / node.node.workers + .5))
			:addTextParametrized("info.analyze.node", {startup = node.node.timing.node.total[1], total = node.node.timing.node.total[2]})
			:addTextParametrized("info.analyze.tree", node.node.timing.tree and {startup = node.node.timing.tree.total[1], total = node.node.timing.tree.total[2]}, true)

		section:addObject(worker)
			:addDivider(nil, true)
	end

	do
		local single = self:create "SectionContainer" {
			title = "info.analyze.heading_single",
			group = "info_timing_single",
			borderless = true,
			no_div = true,
			collapser_pos = "left",
		}

		single
			:addTextParametrized("info.analyze.rows", node.node.raw["Actual Rows"])
			:addTextParametrized("info.analyze.node", {startup = node.node.timing.node.single[1], total = node.node.timing.node.single[2]})
			:addTextParametrized("info.analyze.tree", node.node.timing.tree and {startup = node.node.timing.tree.single[1], total = node.node.timing.tree.single[2]}, true)

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
	covered["Shared I/O Read Time"] = true
	covered["Shared I/O Write Time"] = true
	covered["Local I/O Read Time"] = true
	covered["Local I/O Write Time"] = true
	covered["Temp I/O Read Time"] = true
	covered["Temp I/O Write Time"] = true
	covered["I/O Read Time"] = true
	covered["I/O Write Time"] = true

	self.contentsContainer:createChild "SectionContainer" {
		title = node.node.buffers.Total and ((node.node.buffers.Total.io_read or node.node.buffers.Total.io_write) and "info.buffers.title_io" or "info.buffers.title") or "info.buffers.title_empty",
		group = "info_buffers",
	}
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
	covered["Workers"] = true

	if not node.node.workerDump then
		return
	end

	local locale = self:getObjectClass("Label").locale

	local workers_title = locale:format("info.workers.title", {node.node.workers - 1})

	local workers = self.contentsContainer:createChild "SectionContainer" { title = workers_title, group = "info_workers" }
		:addTextParametrized("info.workers.count", node.node.workers - 1)
		:addDivider(nil, true)

	local master = workers:create "SectionContainer" { title = "info.workers.master_process", group = "info_workers_master", borderless = true }
	self:createWorker(node.node.workerDump[0], master)
	workers:addObject(master)

	for _, worker in ipairs(node.node.workerDump) do ---@cast worker +{no: integer}
		workers:addDivider(nil, true)

		local worker_title = locale:format("info.workers.worker_n", {worker.no})
		local new_worker = workers:create "SectionContainer" { title = worker_title, group = "info_workers_worker_" .. worker.no, borderless = true }
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
			:addTextParametrized("info.analyze.loops", worker.loop_count)
			:addTextParametrized("info.analyze.rows", worker.rows)

		if worker.loop_count == 1 then
			section
				:addTextParametrized("info.analyze.node", {startup = worker.timing.node.single[1], total = worker.timing.node.single[2]})
				:addTextParametrized("info.analyze.tree", worker.timing.tree and {startup = worker.timing.tree.single[1], total = worker.timing.tree.single[2]}, true)
		else
			section
				:addTextParametrized("info.analyze.node_total", {startup = worker.timing.node.total[1], total = worker.timing.node.total[2]})
				:addTextParametrized("info.analyze.node_single", {startup = worker.timing.node.single[1], total = worker.timing.node.single[2]})
				:addTextParametrized("info.analyze.tree_total", worker.timing.tree and {startup = worker.timing.tree.total[1], total = worker.timing.tree.total[2]})
				:addTextParametrized("info.analyze.tree_single", worker.timing.tree and {startup = worker.timing.tree.single[1], total = worker.timing.tree.single[2]})
		end
	end

	if worker.buffers then
		local buffer_group = "info_workers_buffers_worker_" .. (worker.no or "master")

		local buffer_section = self:create "SectionContainer" { title = "info.workers.buffers_title", borderless = true, no_div = true, group = buffer_group, collapser_pos = "left"}

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

	local other_section = self:create "SectionContainer" { title = "info.workers.other", borderless = true, no_div = true, group = other_group, collapser_pos = "left"}

	if worker.wal and (worker.wal.node.records ~= 0 or worker.other) then
		if worker.wal.node.records == 0 then
			other_section:addText("info.wal.no_wal")
		else
			if worker.wal.node.bytes and worker.wal.node.bytes > 0 then
				other_section:addTextParametrized("info.wal.records_bytes", {worker.wal.node.records, worker.wal.node.bytes})
			else
				other_section:addTextParametrized("info.wal.records", worker.wal.node.records)
			end

			if worker.wal.node.fpi_bytes and worker.wal.node.fpi_bytes > 0 then
				other_section:addTextParametrized("info.wal.fpi_bytes", {worker.wal.node.fpi, worker.wal.node.fpi_bytes})
			else
				other_section:addTextParametrized("info.wal.fpi", worker.wal.node.fpi)
			end

			other_section:addTextParametrized("info.wal.buffers_full", worker.wal.node.buffers_full)
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

	local wal = self.contentsContainer:createChild "SectionContainer" { title = "info.output.title" }
		:addTextParametrized("info.output.count", #node.node.raw["Output"])

	if #node.node.raw["Output"] > 0 then
		wal:addText("")
	end

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

	local wal = self.contentsContainer:createChild "SectionContainer" { title = node.node.wal.node.records == 0 and "info.wal.title_none" or node.node.wal.tree and "info.wal.title_tree" or "info.wal.title_node", group = "info_wal" }

	local wal_main = node.node.wal.tree or node.node.wal.node

	if wal_main.records == 0 then
		wal:addText("info.wal.no_wal")
		return
	end

	if wal_main.bytes and wal_main.bytes > 0 then
		wal:addTextParametrized("info.wal.records_bytes", {wal_main.records, wal_main.bytes})
	else
		wal:addTextParametrized("info.wal.records", wal_main.records)
	end

	if wal_main.fpi_bytes and wal_main.fpi_bytes > 0 then
		wal:addTextParametrized("info.wal.fpi_bytes", {wal_main.fpi, wal_main.fpi_bytes})
	else
		wal:addTextParametrized("info.wal.fpi", wal_main.fpi)
	end

	wal:addTextParametrized("info.wal.buffers_full", wal_main.buffers_full)

	if not node.node.wal.tree then
		return
	end

	do
		if node.node.wal.node.records == 0 then
			wal:addText("info.wal.no_wal_node")
			return
		end

		local node_wal = self:create "SectionContainer" {
			title = "info.wal.title_node_short",
			group = "info_wal_node",
			borderless = true,
			no_div = true,
		}

		if node.node.wal.node.bytes and node.node.wal.node.bytes > 0 then
			node_wal:addTextParametrized("info.wal.records_bytes", {node.node.wal.node.records, node.node.wal.node.bytes})
		else
			node_wal:addTextParametrized("info.wal.records", node.node.wal.node.records)
		end

		if node.node.wal.node.fpi_bytes and node.node.wal.node.fpi_bytes > 0 then
			node_wal:addTextParametrized("info.wal.fpi_bytes", {node.node.wal.node.fpi, node.node.wal.node.fpi_bytes})
		else
			node_wal:addTextParametrized("info.wal.fpi", node.node.wal.node.fpi)
		end

		node_wal:addTextParametrized("info.wal.buffers_full", node.node.wal.node.buffers_full)

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
			unknown = unknown or self.contentsContainer:createChild "SectionContainer" { title = "info.other.title" }

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