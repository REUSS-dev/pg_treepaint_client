local conf_defaults = {}

local DEFAULTS = {
    temp_buffers = "8MB",
    work_mem = "4MB",
    hash_mem_multiplier = "2.0",

    effective_io_concurrency = "16",
    maintenance_io_concurrency = "16",
    max_parallel_workers_per_gather = "2",
    max_parallel_workers = "8",
    parallel_leader_participation = "on",

    enable_async_append = "on",
    enable_bitmapscan = "on",
    enable_gathermerge = "on",
    enable_groupagg = "on",
    enable_hashagg = "on",
    enable_hashjoin = "on",
    enable_incremental_sort = "on",
    enable_indexscan = "on",
    enable_indexonlyscan = "on",
    enable_material = "on",
    enable_memoize = "on",
    enable_mergejoin = "on",
    enable_nestloop = "on",
    enable_parallel_append = "on",
    enable_parallel_hash = "on",
    enable_partition_pruning = "on",
    enable_partitionwise_join = "off",
    enable_partitionwise_aggregate = "off",
    enable_presorted_aggregate = "on",
    enable_seqscan = "on",
    enable_sort = "on",
    enable_tidscan = "on",
    enable_group_by_reordering = "on",
    enable_distinct_reordering = "on",
    enable_self_join_elimination = "on",
    enable_eager_aggregate = "on",

    seq_page_cost = "1.0",
    random_page_cost = "4.0",
    cpu_tuple_cost = "0.01",
    cpu_index_tuple_cost = "0.005",
    cpu_operator_cost = "0.0025",
    parallel_setup_cost = "1000.0",
    parallel_tuple_cost = "0.1",
    min_parallel_table_scan_size = "8MB",
    min_parallel_index_scan_size = "512kB",
    effective_cache_size = "4GB",
    min_eager_agg_group_size = "8.0",
    jit_above_cost = "100000",
    jit_inline_above_cost = "500000",
    jit_optimize_above_cost = "500000",

    constraint_exclusion = "partition",
    cursor_tuple_fraction = "0.1",
    from_collapse_limit = "8",
    jit = "on",
    join_collapse_limit = "8",
    plan_cache_mode = "auto",
    recursive_worktable_factor = "10.0",

    geqo = "on",
    geqo_threshold = "12",
    geqo_effort = "5",
    geqo_pool_size = "0",
    geqo_generations = "0",
    geqo_selection_bias = "2.0",
    geqo_seed = "0.0",

    debug_parallel_query = "off",
    optimize_bounded_sort = "on",

    search_path = "",
}

function conf_defaults.get(name)
    return DEFAULTS[name] or ""
end

return conf_defaults