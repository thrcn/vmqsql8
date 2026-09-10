-- Read-only MySQL 8 preflight checks.
-- No SET GLOBAL/SESSION sql_mode changes are made.

SELECT @@version AS mysql_version,
       @@sql_mode AS sql_mode,
       @@character_set_server AS server_charset,
       @@collation_server AS server_collation,
       @@default_storage_engine AS default_engine;

SELECT TABLE_NAME, ENGINE, TABLE_COLLATION, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('pay_order','pay_qrcode','setting','tmp_price')
ORDER BY TABLE_NAME;

SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('pay_order','pay_qrcode','setting','tmp_price')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, SUB_PART, COLLATION
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('pay_order','pay_qrcode','setting','tmp_price')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Zero-date/time check. This schema uses BIGINT timestamps, so the expected result is zero rows.
SELECT 'pay_order' AS table_name, COUNT(*) AS suspicious_rows
FROM pay_order
WHERE close_date < 0 OR create_date < 0 OR pay_date < 0;

-- Duplicate business identifiers are reported but not modified.
SELECT pay_id, COUNT(*) AS duplicate_count
FROM pay_order
WHERE pay_id IS NOT NULL
GROUP BY pay_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM pay_order
WHERE order_id IS NOT NULL
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Orphan amount reservations are reported for manual review.
SELECT tp.price, tp.oid
FROM tmp_price tp
LEFT JOIN pay_order po ON po.order_id = tp.oid
WHERE po.order_id IS NULL;

-- Legacy amount reservations must remain unique because price is the matching lock.
SELECT price, COUNT(*) AS duplicate_count
FROM tmp_price
GROUP BY price
HAVING COUNT(*) > 1;

-- utf8mb4 index-length feasibility for current varchar(255) keys.
-- 255 * 4 = 1020 bytes, below MySQL 8 InnoDB's 3072-byte large-index limit.
SELECT 'varchar(255) utf8mb4 max bytes' AS check_name, 255 * 4 AS bytes_required;

-- GROUP BY audit: application code currently contains no business GROUP BY query;
-- these statements are intentionally simple compatibility probes.
SELECT type, state, COUNT(*) AS row_count
FROM pay_order
GROUP BY type, state;
