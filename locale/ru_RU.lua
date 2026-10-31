local text = {
    header = {
        title = "TreePaint",
        undertext = "Инструмент визуализации деревьев PostgreSQL",

        paste = {
            button = "Вставить из\nбуфера обмена"
        },

        tcp = {
            active = "TCP включен\n{1}",
            inactive = "TCP отключен"
        }
    },

    plan = {
        subquery = "Подзапрос {1}",

        gather = {
            additional_workers = "Доп. воркеры: {1}",
            parallelized = "Параллелизированная секция",
        },

        noplan = {
            header = "Нет плана",
            hint = "План не загружен в визуализатор.\nСкопируйте JSON-вывод предложения EXPLAIN в буфер обмена и нажмите кнопку \"Вставить из буфера обмена\", чтобы просмотреть диаграмму плана.",
            hint_extension = "Попробуйте расширение pg_treepaint для передачи планов напрямую с сервера при помощи EXPLAIN (tp_plan) ...\n(необходимо включить TCP-клиент)",
            extension_button_text = "pg_treepaint GitHub"
        }
    },

    node = {
        time = "Время: {1}мс", -- TIME UNIT
        time_workers = "Время: {2} * {1}мс", -- TIME UNIT
        time_never_executed = "Не исполнялся",
        time_cost = "Стоимость: {1}..{2}",

        Aggregate = {
            strategy = {
                ["Plain"] = "Простой Aggregate",
                ["Hashed"] = "HashAggregate",
                ["Sorted"] = "GroupAggregate",
                ["Mixed"] = "MixedAggregate",
            },

            partial_mode = {
                ["Simple"] = "Нет",
                ["Partial"] = "Частичный",
                ["Finalize"] = "Финализация",
            },

            section = {
                title = "Группировка",

                strategy = "Стратегия: {1}",
                partial = "Частичный режим: {1}",
                planned = "Запланировано батчей: {1}",
                batches = "Создано батчей: {1}",
                peak = "Потребление памяти (в пике): {1}кБ", -- INFO UNIT
                disk = "Использовано на диске: {1}кБ", -- INFO UNIT
                group_by = "Группировка по: {1}",
            }
        },

        BitmapHeapScan = {
            section = {
                exact = "Точных блоков: {1}",
                lossy = "Обобщённых блоков: {1}",
            }
        },

        CTEScan = {
            on_cte = "по CTE {1}",
            on_cte_alias = "по CTE {1} ({2})",

            jump = "Перейти к CTE",

            section = {
                title = "CTE скан",

                cte = "Название CTE: {1}",
                alias = "Алиас скана: {1}",
            }
        },

        Gather = {
            workers = "Воркеров: {1}",

            section = {
                title = "Параллелизация",

                workers_launched = "Запущено воркеров: {1}",
                workers_planned = "Запланировано воркеров: {1}",
                workers_combined = "Запущено воркеров: {1} ({2:plural one='планировался' other='планировалось'} {2})",
            }
        },

        Hash = {
            columns = "Столбцы",

            section = {
                title = "Хеш",

                batches = "Количество батчей: {1}",
                batches_o = "Количество батчей: {1} (изначально: {2})",
                buckets = "Количество вёдер: {1}",
                buckets_o = "Количество вёдер: {1} (изначально: {2})",
                peak = "Потребление памяти (в пике): {1}кБ" -- INFO UNIT
            }
        },

        HashJoin = {
            on = "по {1}",

            section = {
                condition = "Условие: {1}"
            }
        },

        IndexOnlyScan = {
            loops = "Циклов: {1}",

            section = {
                title = "Индекс",

                index = "Индекс: {1}",
                direction = "Направление обхода: {1}",
                searches = "Количество обходов: {1}",
                heap = "Обращений к куче: {1}{1:plural zero='' one=' строка' many=' строк' few=' строки'}",
                condition = "Условие индекса: {1}",
            }
        },

        ModifyTable = {
            operation = {
                ["Insert"] = "Вставка",
                ["Update"] = "Обновление",
                ["Delete"] = "Удаление",
            },

            section = {
                title = "Операция",

                operation = "Вид: {1}",
                schema = "Схема: {1}",
                relation = "Отношение: {1}",
                alias = "Алиас: {1}",
            }
        },

        NestedLoop = {
            on = "на {1}",

            join_type = {
                ["Inner"] = "Внутренний JOIN",
                ["Full"] = "Полный внешний JOIN",
                ["Left"] = "Левый JOIN",
                ["Right"] = "Правый JOIN",
                ["Semi"] = "Полу-соединение",
                ["Anti"] = "Анти-соединение",
            },

            section = {
                title = "Соединение",

                type = "Тип: {1}",
                inner_unique = "Inner unique: {1}",
                relation = "Отношение: {1}"
            }
        },

        SeqScan = {
            on = "на {1}",

            section = {
                title = "Скан",

                schema = "Схема: {1}",
                relation = "Отношение: {1}",
                alias = "Алиас: {1}",
            }
        },

        Sort = {
            by = "по {1}",

            method = {
                quick = "Быстрая сортировка",
                topn_heap = "Пирамидальная Top-N",
            },

            space = {
                ["Memory"] = "ОЗУ",
                ["Disk"] = "Диск",
            },

            section = {
                title = "Сортировка",

                method = "Метод: {1}",
                space = "Использование памяти: {1}kB ({2})",
                order_by = "Сортировка по: {1}",
                order_by_multiple = "Сортировка по ({1}):"
            },
        }
    },

    query = {
        relkind = {
            ['r'] = "Таблица",
            ['i'] = "Индекс",
            ['S'] = "Последовательность",
            ['t'] = "TOAST-таблица",
            ['v'] = "Представление",
            ['m'] = "Мат. представление",
            ['c'] = "Составной тип",
            ['f'] = "Сторонняя таблица",
            ['p'] = "Секционированная таблица",
            ['I'] = "Секционированный индекс"
        },

        rellockmode = {
            [0] = "Нет",
        },

        RTE = {
            title = "RTE #{1}",

            section = {
                title = "RTE #{1}",

                infromcl_true = "Из оригинального запроса: да",
                infromcl_false = "Из оригинального запроса: нет",
                inh = "Наследственное распространение: {1}",
                lateral_false = "LATERAL: отсутствует",
                lateral_true = "LATERAL: присутствует",
                securityquals = "Защитные барьеры: {1}",
                securityquals_null = "Нет защитных барьеров.",
            },

            section_alias = {
                title = "Алиасы",
                alias = "Алиас RTE: {1}",
                colnames_title = "Алиасы столбцов ({1})",
            },

            section_eref = {
                title = "Ярлыки исполнителя",
                eref = "Имя RTE: {1}",
                colnames_title = "Столбцы ({1})",
                colname = "[{1}]: {2}",
                colname_renamed = "[{1}]*: {2}",
                renamedtip = "*Переименованные столбцы"
            },

            section_permissions = {
                title = "RTE - Права доступа",
                title_no = "RTE - Права доступа (пусто)",
                index = "Индекс в rteperminfos: {1}",
                no_check = "Проверка прав доступа не требуется.",
                jump = "Перейти к связанной структуре",
                jump_fail = "<Не удалось определить связанный узел perminfo>",
            },

            relation = {
                title = "RTE #{1} - Отношение",

                section = {
                    title = "Вид: Отношение",
                    relkind = "Тип отношения: {1}",
                    relid = "OID отношения: {1}",
                    inh_true = "Сканировать потомков: да",
                    inh_false = "Сканировать потомков: нет (мод. ONLY)",
                    rellockmode = "Блокировка: {1}",
                    tablesample = "TABLESAMPLE: {1}",
                    tablesample_null = "TABLESAMPLE не задействован.",
                }
            }
        }
    },


    info = {
        head = {
            parent = "Родитель: {1}",
            child = "Потомок: {1}",
            children = "Потомков: {1}",
            children_same = "Потомки ({count}): {name} (x{same_count})",
            children_literal = "Потомки ({count}): {names}",
            child_query = "Имя: {1}",
            cte = "CTE"
        },

        costs = {
            title = "Стоимости",
            width = "Средний размер строки: {1} {1:plural one = 'байт' many = 'байтов' other = 'байта'}",
            rows = "Ожидается строк: {1}",
            cost = "Стоимость: {startup}..{total}",
            tree = "Стоимость поддрева: {startup}..{total}",
        },

        analyze = {
            title = "Тайминги",
            title_never_executed = "Тайминги (Не исполнялся)",
            title_parallel = "Тайминги (параллелизация)",
            heading_worker = "Один воркер",
            heading_single = "Одна итерация",
            never_executed = "Не исполнялся",
            workers = "Воркеры: {1}",
            loops = "Кол-во итераций: {1}", -- AMOUNT UNIT
            rows = "Кол-во строк: {1}", -- AMOUNT UNIT
            node = "Время узла: {startup}..{total}мс", -- TIME UNIT
            tree = "Время поддрева: {startup}..{total}мс", -- TIME UNIT
        },

        filters = {
            title = "Фильтры",
            total_rows = "Всего исключено строк: {1}",
            filter_rows = "Строк исключено фильтром: {1}",
            filter = "Фильтр: {1}",
            join_filter_rows = "Строк исключено JOIN фильтром: {1}",
            join_filter = "JOIN фильтр: {1}",
            index_filter_rows = "Строк исключено перепроверкой индекса: {1}",
            index_filter = "Условие индекса: {1}",
            bitmap_filter = "Условие перепроверки: {1}",
        },

        buffers = {
            title = "Буферы",
            title_io = "Буферы + IO тайминги",
            title_empty = "Буферы (нет)",
            ---@see text.buffers at the bottom
        },

        workers = {
            title = "Воркеры ({1})",
            count = "Доп. воркеры: {1}",
            master_process = "Основной процесс",
            worker_n = "Воркер {1}",
            buffers_title = "Буферы",
            other = "Прочее"
        },

        output = {
            title = "Выходные данные",
            count = "Кол-во столбцов: {1}",
        },

        wal = {
            title_none = "WAL-записи (Пусто)",
            title_node = "WAL-записи (Узел)",
            title_tree = "WAL-записи (Поддерево)",
            title_node_short = "Узел",
            no_wal = "Новых WAL-записей не было создано.",
            no_wal_node = "\nУзел не создал новых WAL-записей.",
            records = "Создано записей: {1}",
            records_bytes = "Создано записей: {1} ({2} {2:plural one = 'байт' many='байтов' other = 'байта'})", -- INFO UNIT
            fpi = "FPI: {1}",
            fpi_bytes = "FPI: {1} ({2} {2:plural one = 'байт' many='байтов' other = 'байта'})", -- INFO UNIT
            buffers_full = "Буферов заполнено: {1}"
        },

        other = {
            title = "Прочее"
        },

        properties = {
            title_active = "Свойства",
            title_inactive = "Неактивные свойства",
            property = "{name}: {value}",
            property_string = "{name}: \"{value}\"",
            property_blist = "{name} bitmap: {value}",
            property_ilist = "{name} список: {value}",
            property_datum = "{name} датум: {value}",
            property_null = "{name}: Null",

        },

        list = {
            title = "Список",
            size = "Длина списка: {1} {1:plural one='элемент' few='элемента' many='элементов' other='элемента'}"
        }
    },

    summary = {
        tabs = {
            info = "Сводка",
            subplans = "Подпланы",
            stats = "Показатели",
            insights = "Советы"
        },

        info = {
            head = {
                title = "Запрос {1}",
                nodes = "{1} {1:plural one='узел' many='узлов' other = 'узла'}",
                subplan = "{1} {1:plural one='подплан' many='подпланов' other = 'подплана'}",
            },

            diagrams = {
                title = "Диаграммы",
                plan = "План",
                query = "Запрос",
                query_rewritten = "Запрос (переписанный)"
            },

            timing = {
                title = "Тайминг",
                execution = "Время исполнения: {1}мс", -- TIME UNIT
                planning = "Время планирования: {1}мс", -- TIME UNIT
                total = "Итого: {1}мс", -- TIME UNIT
            },

            buffers = {
                title = "Буферы (итого)",
                title_io = "Буферы + IO (итого)",
                title_planning = "Буферы (планировщик)",
                planning_tip = "Использование буферов планировщиком включено в \"итого\"",
            },

            output = {
                title = "Выходные данные",
                rows = "Число строк: {1}", -- AMOUNT UNIT
                columns = "Столбцы ({1})",
            },

            wal = {
                title = "WAL",
            },

            identifier = {
                title = "Идентификатор запроса"
            },

            settings = {
                title = "Конфигурация сервера",
                parameter = "Параметр",
                default = "Default (pg 18)"
            }
        }
    },

    buffers = {
        no_buffers = "Буферы не задействованы.",
        Shared = "Shared",
        Local = "Local",
        Temp = "Temp",
        total = "Итого",
        Hit = "Hit",
        Read = "Read",
        Dirtied = "Dirtied",
        Written = "Written",
    }
}

return {
    text = text,
    extends = "en"
}