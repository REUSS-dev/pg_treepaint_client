local text = {
    header = {
        title = "TreePaint",
        undertext = "A PostgreSQL Tree Visualization Tool",

        paste = {
            button = "Plot\nfrom clipboard"
        },

        tcp = {
            active = "TCP Active\n{1}",
            inactive = "TCP Inactive"
        }
    },

    plan = {
        subquery = "Subquery {1}",

        gather = {
            additional_workers = "Additional workers: {1}",
            parallelized = "Parallelized",
        }
    },

    node = {
        time = "Time: {1}ms", -- TIME UNIT
        time_workers = "Time: {2} * {1}ms", -- TIME UNIT
        time_never_executed = "Never Executed",
        time_cost = "Cost: {1}..{2}",

        Aggregate = {
            strategy = {
                ["Plain"] = "Plain Aggregate",
                ["Hashed"] = "HashAggregate",
                ["Sorted"] = "GroupAggregate",
                ["Mixed"] = "MixedAggregate",
            },

            partial_mode = {
                ["Simple"] = "No",
                ["Partial"] = "Partial",
                ["Finalize"] = "Finalize",
            },

            section = {
                title = "Aggregate Info",

                strategy = "Strategy: {1}",
                partial = "Partial Mode: {1}",
                planned = "Planned Batches: {1}",
                batches = "Actual Batches: {1}",
                peak = "Peak Memory Usage: {1}kB", -- INFO UNIT
                disk = "Disk Usage: {1}kB", -- INFO UNIT
                group_by = "Group by: {1}",
            }
        },

        BitmapHeapScan = {
            section = {
                exact = "Exact Heap Blocks: {1}",
                lossy = "Lossy Heap Blocks: {1}",
            }
        },

        CTEScan = {
            on_cte = "On CTE {1}",
            on_cte_alias = "On CTE {1} ({2})",

            jump = "Jump to CTE",

            section = {
                title = "Scan Info",

                cte = "CTE Name: {1}",
                alias = "Alias: {1}",
            }
        },

        Gather = {
            workers = "Workers: {1}",

            section = {
                title = "Gather Info",

                workers_launched = "Workers Launched: {1}",
                workers_planned = "Workers Planned: {1}",
                workers_combined = "Workers Launched: {1} ({2} planned)",
            }
        },

        Hash = {
            columns = "Columns",

            section = {
                title = "Hash Info",

                batches = "Hash Batches: {1}",
                batches_o = "Hash Batches: {1} (original: {2})",
                buckets = "Hash Buckets: {1}",
                buckets_o = "Hash Buckets: {1} (original: {2})",
                peak = "Peak Memory Usage: {1}kB" -- INFO UNIT
            }
        },

        HashJoin = {
            on = "on {1}",

            section = {
                condition = "Hash Condition: {1}"
            }
        },

        IndexOnlyScan = {
            loops = "Loops: {1}",

            section = {
                title = "Index Info",

                index = "Index: {1}",
                direction = "Scan Direction: {1}",
                searches = "Index Searches: {1}",
                heap = "Heap fetches: {1}{1:plural zero='' one=' row' other=' rows'}",
            }
        },

        ModifyTable = {
            operation = {
                ["Insert"] = "Insert",
                ["Update"] = "Update",
                ["Delete"] = "Delete",
            },

            section = {
                title = "Modify Info",

                operation = "Operation: {1}",
                schema = "Schema: {1}",
                relation = "Relation: {1}",
                alias = "Alias: {1}",
            }
        },

        NestedLoop = {
            on = "on {1}",

            join_type = {
                ["Inner"] = "Inner join",
                ["Full"] = "Full join",
                ["Left"] = "Left join",
                ["Right"] = "Right join",
                ["Semi"] = "Semi-join",
                ["Anti"] = "Anti-join",
            },

            section = {
                title = "Join Info",

                type = "Type: {1}",
                inner_unique = "Inner unique: {1}",
                relation = "Join Relation: {1}"
            }
        },

        SeqScan = {
            on = "on {1}",

            section = {
                title = "Scan Info",

                schema = "Schema: {1}",
                relation = "Relation: {1}",
                alias = "Alias: {1}",
            }
        },

        Sort = {
            by = "by {1}",

            method = {
                quick = "Quick Sort",
                topn_heap = "Top-N Heapsort",
            },

            space = {
                ["Memory"] = "Memory",
                ["Disk"] = "Disk",
            },

            section = {
                title = "Sort Info",
                method = "Method: {1}",
                space = "Space used: {1}kB ({2})",
                order_by = "Order by: {1}",
                order_by_multiple = "Order by ({1}):",
            },
        }
    },

    info = {
        head = {
            parent = "Parent: {1}",
            child = "Child: {1}",
            children = "{1:plural one='Child' other='Children'}: {1}",
            children_same = "Children ({count}): {name} (x{same_count})",
            children_literal = "Children ({count}): {names}",
            cte = "CTE"
        },

        costs = {
            title = "Costs",
            width = "Plan Width: {1} {1:plural one = 'byte' other = 'bytes'}", -- INFO UNIT
            rows = "Plan Rows: {1}", -- AMOUNT UNIT
            cost = "Cost: {startup}..{total}", -- AMOUNT UNIT
            tree = "Tree: {startup}..{total}", -- AMOUNT UNIT
        },

        analyze = {
            title = "Timing Info",
            title_never_executed = "Timing Info (Never Executed)",
            title_parallel = "Timing Info (Parallel)",
            heading_worker = "Single Worker",
            heading_single = "Single Time",
            never_executed = "Never Executed",
            workers = "Workers: {1}",
            loops = "Loops: {1}", -- AMOUNT UNIT
            rows = "Rows: {1}", -- AMOUNT UNIT
            node = "Node: {startup}..{total}ms", -- TIME UNIT
            tree = "Tree: {startup}..{total}ms", -- TIME UNIT
            node_total = "Node (total): {startup}..{total}ms", -- TIME UNIT
            node_single = "Node (single time): {startup}..{total}ms", -- TIME UNIT
            tree_total = "Tree (total): {startup}..{total}ms", -- TIME UNIT
            tree_single = "Tree (single time): {startup}..{total}ms", -- TIME UNIT
        },

        buffers = {
            title = "Buffers Info"
            ---@see text.buffers at the bottom
        },

        workers = {
            title = "Workers ({1})",
            count = "Additional Workers: {1}",
            master_process = "Master Process",
            worker_n = "Worker {1}",
            buffers_title = "Buffers",
            other = "Other"
        },

        output = {
            title = "Output Info",
            count = "Output Count: {1}",
        },

        wal = {
            title_none = "WAL Info (None)",
            title_node = "WAL Info (Node)",
            title_tree = "WAL Info (Tree)",
            title_node_short = "Node",
            no_wal = "No WAL Records created.",
            no_wal_node = "\nNo WAL Records created by Node.",
            records = "Records: {1}",
            records_bytes = "Records: {1} ({2} {2:plural one = 'byte' other = 'bytes'})", -- INFO UNIT
            fpi = "FPI: {1}",
            fpi_bytes = "FPI: {1} ({2} {2:plural one = 'byte' other = 'bytes'})", -- INFO UNIT
            buffers_full = "Buffers Full: {1}"
        },

        other = {
            title = "Other"
        }
    },

    summary = {
        tabs = {
            info = "Info",
            subplans = "Subplans",
            stats = "Stats",
            insights = "Insights"
        },

        info = {
            head = {
                title = "{1} Query",
                nodes = "{1} {1:plural one = 'node', other = 'nodes'}",
                subplan = "{1} {1:plural one = 'subplan', other = 'subplans'}",
            },

            timing = {
                title = "Timing",
                execution = "Execution time: {1}ms", -- TIME UNIT
                planning = "Planning time: {1}ms", -- TIME UNIT
                total = "Total: {1}ms", -- TIME UNIT
            },

            buffers = {
                title = "Buffers (total)",
                title_planning = "Buffers (planning)",
                planning_tip = "Planning buffer usage is included in total",
            },

            output = {
                title = "Output",
                rows = "Output Rows: {1}", -- AMOUNT UNIT
                columns = "Output Columns ({1})",
            },

            wal = {
                title = "WAL"
            },

            identifier = {
                title = "Query Identifier"
            },

            settings = {
                title = "Settings",
                parameter = "Parameter",
                default = "Default (pg 18)"
            }
        }
    },

    buffers = {
        no_buffers = "No buffers utilized.",
        Shared = "Shared",
        Local = "Local",
        Temp = "Temp",
        total = "Total",
        Hit = "Hit",
        Read = "Read",
        Dirtied = "Dirtied",
        Written = "Written",
    }
}

return {
    text = text,
}