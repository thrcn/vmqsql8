-- Read-only post-migration data consistency checks.
-- Run before and after migration and compare the result sets.

SELECT 'pay_order.count' AS check_name, COUNT(*) AS value FROM pay_order;
SELECT 'pay_order.id_sum' AS check_name, COALESCE(SUM(id),0) AS value FROM pay_order;
SELECT 'pay_order.price_sum' AS check_name, COALESCE(SUM(price),0) AS value FROM pay_order;
SELECT 'pay_order.really_price_sum' AS check_name, COALESCE(SUM(really_price),0) AS value FROM pay_order;
SELECT 'pay_order.state_-1' AS check_name, COUNT(*) AS value FROM pay_order WHERE state = -1;
SELECT 'pay_order.state_0' AS check_name, COUNT(*) AS value FROM pay_order WHERE state = 0;
SELECT 'pay_order.state_1' AS check_name, COUNT(*) AS value FROM pay_order WHERE state = 1;
SELECT 'pay_order.state_2' AS check_name, COUNT(*) AS value FROM pay_order WHERE state = 2;
SELECT 'pay_order.type_1' AS check_name, COUNT(*) AS value FROM pay_order WHERE type = 1;
SELECT 'pay_order.type_2' AS check_name, COUNT(*) AS value FROM pay_order WHERE type = 2;

SELECT 'pay_qrcode.count' AS check_name, COUNT(*) AS value FROM pay_qrcode;
SELECT 'pay_qrcode.id_sum' AS check_name, COALESCE(SUM(id),0) AS value FROM pay_qrcode;
SELECT 'setting.count' AS check_name, COUNT(*) AS value FROM setting;
SELECT 'tmp_price.count' AS check_name, COUNT(*) AS value FROM tmp_price;

-- Stable, order-independent fingerprints for detecting unexpected value changes.
SELECT 'pay_order.fingerprint' AS check_name,
       COALESCE(BIT_XOR(CRC32(CONCAT_WS('|',
           id, close_date, create_date, is_auto, notify_url, order_id,
           param, pay_date, pay_id, pay_url, price, really_price,
           return_url, state, type))),0) AS value
FROM pay_order;

SELECT 'pay_qrcode.fingerprint' AS check_name,
       COALESCE(BIT_XOR(CRC32(CONCAT_WS('|',id,pay_url,price,type))),0) AS value
FROM pay_qrcode;

SELECT 'setting.fingerprint' AS check_name,
       COALESCE(BIT_XOR(CRC32(CONCAT_WS('|',vkey,vvalue))),0) AS value
FROM setting;

SELECT 'tmp_price.fingerprint' AS check_name,
       COALESCE(BIT_XOR(CRC32(CONCAT_WS('|',price,oid))),0) AS value
FROM tmp_price;

-- Referential consistency used by the legacy application: every reservation must point to an order.
SELECT COUNT(*) AS orphan_tmp_price_rows
FROM tmp_price tp
LEFT JOIN pay_order po ON po.order_id = tp.oid
WHERE po.order_id IS NULL;

-- The matching reservation key must remain unique.
SELECT price, COUNT(*) AS duplicate_count
FROM tmp_price
GROUP BY price
HAVING COUNT(*) > 1;
