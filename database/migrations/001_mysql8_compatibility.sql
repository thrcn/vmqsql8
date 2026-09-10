-- V免签 -> MySQL 8.x compatibility migration
-- Run during maintenance. This migration intentionally does NOT change SQL_MODE.
-- It preserves the legacy column types and API-visible data semantics.
-- Prerequisite: run database/checks/001_preflight.sql and resolve any reported blockers.

SET @old_foreign_key_checks := @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE `pay_order`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  MODIFY `close_date` bigint(20) NOT NULL DEFAULT 0,
  MODIFY `create_date` bigint(20) NOT NULL DEFAULT 0,
  MODIFY `is_auto` int(11) NOT NULL DEFAULT 0,
  MODIFY `pay_date` bigint(20) NOT NULL DEFAULT 0,
  MODIFY `price` double NOT NULL DEFAULT 0,
  MODIFY `really_price` double NOT NULL DEFAULT 0,
  MODIFY `state` int(11) NOT NULL DEFAULT 0,
  MODIFY `type` int(11) NOT NULL DEFAULT 0;

ALTER TABLE `pay_order`
  ADD INDEX `idx_pay_order_pay_id` (`pay_id`),
  ADD INDEX `idx_pay_order_order_id` (`order_id`),
  ADD INDEX `idx_pay_order_match` (`type`,`state`,`really_price`),
  ADD INDEX `idx_pay_order_create_state` (`create_date`,`state`);

ALTER TABLE `pay_qrcode`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  MODIFY `price` double NOT NULL DEFAULT 0,
  MODIFY `type` int(11) NOT NULL DEFAULT 0;

ALTER TABLE `pay_qrcode`
  ADD INDEX `idx_pay_qrcode_type_price` (`type`,`price`);

ALTER TABLE `setting`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tmp_price`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tmp_price`
  ADD INDEX `idx_tmp_price_oid` (`oid`);

SET FOREIGN_KEY_CHECKS = @old_foreign_key_checks;
