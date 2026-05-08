-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               9.1.0 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.15.0.7171
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for quan_ao
CREATE DATABASE IF NOT EXISTS `quan_ao` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `quan_ao`;

-- Dumping structure for table quan_ao.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `active` tinyint DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table quan_ao.categories: 3 rows

DELETE FROM `categories`;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` (`id`, `name`, `active`) VALUES
	(1, 'Áo', 1),
	(2, 'Quần', 0),
	(3, 'ss', 1);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;

-- Dumping structure for table quan_ao.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table quan_ao.roles: 2 rows
DELETE FROM `roles`;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`, `name`) VALUES
	(1, 'USER'),
	(2, 'ADMIN');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;

-- Dumping structure for table quan_ao.user_roles
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table quan_ao.user_roles: 2 rows
DELETE FROM `user_roles`;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
	(1, 1),
	(2, 2);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;

-- Dumping structure for table quan_ao.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(191) COLLATE utf8mb4_general_ci NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `google_id` varchar(191) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `avatar` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `verified` tinyint DEFAULT '0',
  `code_active` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `active` tinyint DEFAULT '1',
  `failed_attempts` int DEFAULT '0',
  `lock_until` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `google_id` (`google_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `users` 
ADD COLUMN `phone` varchar(20) AFTER `full_name`,
ADD COLUMN `address` text AFTER `phone`;
-- Dumping data for table quan_ao.users: 1 rows
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `email`, `username`, `password`, `google_id`, `full_name`, `avatar`, `created_at`, `verified`, `code_active`, `active`, `failed_attempts`, `lock_until`) VALUES
	(2, 'ltphat240103@gmail.com', 'misaki', '$2a$10$ASw7jvu1FpSq0YdGKCLV9uBmDMyTiS8LzDMZvqByxJwJAbDABGNQe', '109614134023219518628', 'Phát Lê Tuấn', NULL, '2026-05-03 07:30:56', 1, 'bf1caef0-9c43-4ccc-bfc2-fd3474b59824', 1, 0, NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

CREATE TABLE `products` (
  `productId` int NOT NULL AUTO_INCREMENT,
  `productName` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `productBrand` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `productPrice` double NOT NULL DEFAULT '0',
  `quantity` int NOT NULL DEFAULT '0', -- Số lượng tồn kho
  `productDescription` text COLLATE utf8mb4_general_ci,
  `productImage` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `categoryId` int DEFAULT NULL,
  `productStatus` int DEFAULT '1', -- 1: Đang bán, 0: Ngừng bán
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`productId`),
  KEY `fk_product_category` (`categoryId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `products` 
(`productName`, `productBrand`, `productPrice`, `quantity`, `productDescription`, `productImage`, `categoryId`, `productStatus`) 
VALUES
('Áo thun Unisex Basic', 'Local Brand', 150000, 100, 'Chất liệu cotton thoáng mát', 'https://via.placeholder.com/200', 1, 1),
('Quần Jean Slimfit', 'Levis', 450000, 50, 'Quần jean co giãn nhẹ', 'https://via.placeholder.com/200', 2, 1),
('Áo Khoác Bomber', 'ZARA', 650000, 30, 'Áo khoác giữ ấm tốt', 'https://via.placeholder.com/200', 1, 1);

CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` varchar(50) NOT NULL,        
  `user_id` int NOT NULL,                     
  `full_name` varchar(255) NOT NULL,      
  `phone` varchar(10) NOT NULL,              
  `address` text NOT NULL,                
  `total_price` double NOT NULL DEFAULT '0', 
  `status` varchar(50) DEFAULT 'Chờ xác nhận',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `fk_order_user` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` double NOT NULL,                  
  PRIMARY KEY (`id`),
  KEY `fk_detail_order` (`order_id`),
  KEY `fk_detail_product` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orders` (`order_id`, `user_id`, `full_name`, `phone`, `address`, `total_price`, `status`, `created_at`) VALUES
('ORD-TEST001', 5, 'Người Dùng Test', '0987654321', '123 Đường ABC, Quận 1, HCM', 300000, 'Chờ xác nhận', '2026-05-01 10:00:00'),
('ORD-TEST002', 5, 'Người Dùng Test', '0987654321', '123 Đường ABC, Quận 1, HCM', 450000, 'Đang giao', '2026-05-02 14:30:00'),
('ORD-TEST003', 5, 'Người Dùng Test', '0987654321', '123 Đường ABC, Quận 1, HCM', 150000, 'Đã hủy', '2026-05-03 09:15:00');
SET SQL_SAFE_UPDATES = 0;
UPDATE `user_roles` 
SET `role_id` = 2
WHERE `user_id` = 5;

CREATE TABLE IF NOT EXISTS `invoices` (
  `invoice_id` varchar(50) NOT NULL,
  `order_id` varchar(50) NOT NULL,
  `admin_id` int DEFAULT NULL, -- Lưu người lập hóa đơn
  `customer_name` varchar(255) NOT NULL,
  `total_amount` double NOT NULL DEFAULT '0',
  `payment_method` varchar(100) DEFAULT 'Tiền mặt',
  `payment_status` varchar(50) DEFAULT 'Chưa thanh toán',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`invoice_id`),
  UNIQUE KEY `unique_order_invoice` (`order_id`), 
  KEY `fk_invoice_user` (`admin_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `invoices` (`invoice_id`, `order_id`, `admin_id`, `customer_name`, `total_amount`, `payment_status`) VALUES
('INV-2026-001', 'ORD-TEST001', 2, 'Người Dùng Test', 300000, 'Đã thanh toán');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
SET SQL_SAFE_UPDATES = 0;
