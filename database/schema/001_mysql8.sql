-- V免签 MySQL 8.x baseline schema
-- Compatible with the existing TP5.1 application contract.
-- No SQL_MODE changes are performed here.

CREATE TABLE `pay_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `close_date` bigint(20) NOT NULL DEFAULT 0,
  `create_date` bigint(20) NOT NULL DEFAULT 0,
  `is_auto` int(11) NOT NULL DEFAULT 0,
  `notify_url` varchar(255) DEFAULT NULL,
  `order_id` varchar(255) DEFAULT NULL,
  `param` varchar(255) DEFAULT NULL,
  `pay_date` bigint(20) NOT NULL DEFAULT 0,
  `pay_id` varchar(255) DEFAULT NULL,
  `pay_url` varchar(255) DEFAULT NULL,
  `price` double NOT NULL DEFAULT 0,
  `really_price` double NOT NULL DEFAULT 0,
  `return_url` varchar(255) DEFAULT NULL,
  `state` int(11) NOT NULL DEFAULT 0,
  `type` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pay_order_pay_id` (`pay_id`),
  KEY `idx_pay_order_order_id` (`order_id`),
  KEY `idx_pay_order_match` (`type`,`state`,`really_price`),
  KEY `idx_pay_order_create_state` (`create_date`,`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pay_qrcode` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pay_url` varchar(255) DEFAULT NULL,
  `price` double NOT NULL DEFAULT 0,
  `type` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pay_qrcode_type_price` (`type`,`price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `setting` (
  `vkey` varchar(255) NOT NULL,
  `vvalue` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`vkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tmp_price` (
  `price` varchar(255) NOT NULL,
  `oid` varchar(255) NOT NULL,
  PRIMARY KEY (`price`),
  KEY `idx_tmp_price_oid` (`oid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `setting` (`vkey`, `vvalue`) VALUES
('user', 'admin'),
('pass', 'admin'),
('notifyUrl', ''),
('returnUrl', ''),
('key', ''),
('lastheart', '0'),
('lastpay', '0'),
('jkstate', '-1'),
('close', '5'),
('payQf', '1'),
('wxpay', ''),
('zfbpay', '');
