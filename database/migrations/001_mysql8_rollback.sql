-- Rollback for 001_mysql8_compatibility.sql.
-- IMPORTANT: this restores the legacy table engines/charset/default shape only.
-- It cannot restore rows that were independently changed after migration.
-- Stop application writes before rollback.

SET @old_foreign_key_checks := @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE `pay_order`
  DROP INDEX `idx_pay_order_pay_id`,
  DROP INDEX `idx_pay_order_order_id`,
  DROP INDEX `idx_pay_order_match`,
  DROP INDEX `idx_pay_order_create_state`;

ALTER TABLE `pay_order`
  ENGINE=MyISAM,
  CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci,
  MODIFY `close_date` bigint(20) NOT NULL,
  MODIFY `create_date` bigint(20) NOT NULL,
  MODIFY `is_auto` int(11) NOT NULL,
  MODIFY `pay_date` bigint(20) NOT NULL,
  MODIFY `price` double NOT NULL,
  MODIFY `really_price` double NOT NULL,
  MODIFY `state` int(11) NOT NULL,
  MODIFY `type` int(11) NOT NULL;

ALTER TABLE `pay_qrcode`
  DROP INDEX `idx_pay_qrcode_type_price`;

ALTER TABLE `pay_qrcode`
  ENGINE=MyISAM,
  CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci,
  MODIFY `price` double NOT NULL,
  MODIFY `type` int(11) NOT NULL;

ALTER TABLE `setting`
  ENGINE=MyISAM,
  CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;

ALTER TABLE `tmp_price`
  DROP INDEX `idx_tmp_price_oid`;

ALTER TABLE `tmp_price`
  ENGINE=MyISAM,
  CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;

SET FOREIGN_KEY_CHECKS = @old_foreign_key_checks;
