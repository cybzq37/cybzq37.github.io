查看 hypertable 的分区间隔：
```sql
SELECT
  ht.table_name,
  ds.interval_length,
  (ds.interval_length / 86400000000.0) AS chunk_interval_in_days
FROM _timescaledb_catalog.hypertable ht
JOIN _timescaledb_catalog.dimension ds 
  ON ht.id = ds.hypertable_id
WHERE ds.interval_length IS NOT NULL;
```

查看chunk详细信息：
```sql
SELECT * FROM timescaledb_information.chunks WHERE hypertable_name = 'device_trace';
```

调整chunk的interval：
```sql
SELECT set_chunk_time_interval('device_trace', INTERVAL '1 day');
```

查看chunk的大小：
```sql
SELECT
  h.table_name AS hypertable,
  c.schema_name || '.' || c.table_name AS chunk,
  pg_size_pretty(pg_table_size((c.schema_name || '.' || c.table_name)::regclass)) AS chunk_size
FROM _timescaledb_catalog.chunk c
JOIN _timescaledb_catalog.hypertable h
  ON c.hypertable_id = h.id
ORDER BY h.table_name, c.table_name;
```

数据保留策略：
```sql
-- 保留最近3个月的数据
SELECT add_retention_policy('device_trace', INTERVAL '3 months');
-- 查看当前所有的数据保留策略
  SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_retention';
-- 移除数据保留策略
  SELECT remove_retention_policy('device_trace');
```