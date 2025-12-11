-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 10, 2025 at 09:03 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inventaris_barang`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proses_peminjaman` (IN `p_id_peminjam` INT, IN `p_kode_barang` VARCHAR(50), IN `p_jumlah` INT, IN `p_tgl_pinjam` DATE, IN `p_dl_kembali` DATE)   BEGIN
    DECLARE v_tersedia INT;
    
    -- Cek ketersediaan
    SELECT jumlah_tersedia INTO v_tersedia 
    FROM barang 
    WHERE kode_barang = p_kode_barang;
    
    IF v_tersedia >= p_jumlah THEN
        -- Insert peminjaman
        INSERT INTO borrow (id_peminjam, kode_barang, jumlah_pinjam, tgl_peminjaman, tgl_pinjam, dl_kembali, status_barang)
        VALUES (p_id_peminjam, p_kode_barang, p_jumlah, CURDATE(), p_tgl_pinjam, p_dl_kembali, 'pending');
        
        -- Update jumlah tersedia
        UPDATE barang 
        SET jumlah_tersedia = jumlah_tersedia - p_jumlah
        WHERE kode_barang = p_kode_barang;
        
        SELECT 'SUCCESS' AS status, 'Peminjaman berhasil diajukan' AS message;
    ELSE
        SELECT 'FAILED' AS status, 'Stok tidak mencukupi' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proses_pengembalian` (IN `p_id_peminjaman` INT, IN `p_kondisi` VARCHAR(50), IN `p_foto` VARCHAR(255))   BEGIN
    DECLARE v_kode_barang VARCHAR(50);
    DECLARE v_jumlah INT;
    
    -- Ambil data peminjaman
    SELECT kode_barang, jumlah_pinjam 
    INTO v_kode_barang, v_jumlah
    FROM borrow 
    WHERE id_peminjaman = p_id_peminjaman;
    
    -- Update peminjaman
    UPDATE borrow 
    SET status_barang = 'dikembalikan',
        tgl_kembali = CURDATE(),
        kondisi_barang = p_kondisi,
        foto_pengembalian = p_foto
    WHERE id_peminjaman = p_id_peminjaman;
    
    -- Kembalikan stok
    UPDATE barang 
    SET jumlah_tersedia = jumlah_tersedia + v_jumlah
    WHERE kode_barang = v_kode_barang;
    
    SELECT 'SUCCESS' AS status, 'Pengembalian berhasil' AS message;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_admin` int(11) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_admin`, `id_user`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `id_barang` int(11) NOT NULL,
  `id_instansi` int(11) DEFAULT NULL,
  `kode_barang` varchar(50) NOT NULL,
  `nama_barang` varchar(100) NOT NULL,
  `lokasi_barang` varchar(100) DEFAULT NULL,
  `jumlah_total` int(11) DEFAULT 0,
  `jumlah_tersedia` int(11) DEFAULT 0,
  `deskripsi` text DEFAULT NULL,
  `kondisi_barang` enum('baik','rusak ringan','rusak berat') DEFAULT 'baik',
  `status` enum('tersedia','dipinjam','rusak','hilang') DEFAULT 'tersedia',
  `foto` varchar(255) DEFAULT NULL,
  `foto_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`id_barang`, `id_instansi`, `kode_barang`, `nama_barang`, `lokasi_barang`, `jumlah_total`, `jumlah_tersedia`, `deskripsi`, `kondisi_barang`, `status`, `foto`, `foto_url`, `created_at`, `updated_at`) VALUES
(1, 1, 'BRG-001', 'Proyektor Epson', 'Ruang Lab 1', 5, 5, 'Proyektor untuk presentasi', 'baik', 'tersedia', NULL, '/images/barang/ProyektorEPSON.jpg', '2025-11-15 22:36:36', '2025-12-07 11:35:18'),
(2, 1, 'BRG-002', 'Laptop Dell Latitude', 'Ruang Admin', 10, 5, 'Laptop untuk mahasiswa', 'baik', 'tersedia', NULL, '/images/barang/LaptopDELL.jpg', '2025-11-15 22:36:36', '2025-12-07 11:36:05'),
(3, 1, 'BRG-003', 'Kamera Canon EOS', 'Ruang Media', 3, 2, 'Kamera DSLR untuk dokumentasi', 'baik', 'tersedia', NULL, '/images/barang/KameraCANON.jpg', '2025-11-15 22:36:36', '2025-12-07 11:36:33'),
(4, NULL, 'BRG-004', 'Sound System', 'Aula', 2, 2, 'Sound system untuk acara', 'baik', 'tersedia', NULL, '/images/barang/SoundSystem.jpg', '2025-11-15 22:36:36', '2025-12-07 11:37:02'),
(5, NULL, 'BRG-005', 'Meja Lipat', 'Gudang', 50, 45, 'Meja lipat untuk event', 'baik', 'tersedia', NULL, '/images/barang/MejaLipat.jpg', '2025-11-15 22:36:36', '2025-12-07 11:38:03'),
(6, 2, 'PGSD-001', 'Bendera', 'Ruang HIMA PGSD', 7, 7, 'Barang milik HIMA PGSD', 'baik', 'tersedia', NULL, '/images/barang/Bendera.jpg', '2025-11-17 22:09:22', '2025-12-10 16:01:51'),
(7, 2, 'PGSD-002', 'Capybara limited', 'Gudang PGSD', 0, 0, 'Limited edition', 'baik', 'tersedia', NULL, '/images/barang/Monyet.JPEG', '2025-11-17 22:09:22', '2025-12-07 11:51:54'),
(8, 2, 'PGSD-003', 'Indomilk rasa Duren', 'Pantry PGSD', 0, 0, 'Stok habis', 'baik', 'tersedia', NULL, '/images/barang/Yasir.jpg', '2025-11-17 22:09:22', '2025-11-30 01:22:16'),
(9, 2, 'PGSD-004', 'Buku Anak SD', 'Ruang HIMA PGSD', 4, 4, 'Tersedia', 'baik', 'tersedia', NULL, '/images/barang/BukuSD.jpg', '2025-11-17 22:09:22', '2025-12-07 11:44:33'),
(10, 4, 'PSTI-001', 'Laptop Programming', 'Lab PSTI', 10, 3, 'Untuk coding', 'baik', 'tersedia', NULL, '/images/barang/LaptopProgramming.jpg', '2025-11-17 22:09:22', '2025-12-07 16:12:54'),
(11, 4, 'PSTI-002', 'Arduino Kit', 'Lab PSTI', 15, 15, 'Kit lengkap', 'baik', 'tersedia', NULL, '/images/barang/ArduinoKit.jpeg', '2025-11-17 22:09:22', '2025-12-07 16:03:46'),
(12, 4, 'PSTI-003', 'Bola Basket', 'lapangan voli', 6, 4, 'basket', 'baik', 'tersedia', NULL, '/images/barang/basket.jpg', '2025-11-17 23:17:04', '2025-12-10 15:58:17');

-- --------------------------------------------------------

--
-- Table structure for table `borrow`
--

CREATE TABLE `borrow` (
  `id_peminjaman` int(11) NOT NULL,
  `id_peminjam` int(11) NOT NULL,
  `id_admin` int(11) DEFAULT NULL,
  `kode_barang` varchar(50) NOT NULL,
  `jumlah_pinjam` int(11) NOT NULL,
  `kondisi_barang` varchar(50) DEFAULT NULL,
  `tgl_peminjaman` date NOT NULL,
  `tgl_pinjam` date NOT NULL,
  `tgl_kembali` date DEFAULT NULL,
  `dl_kembali` date NOT NULL,
  `foto_pengembalian` varchar(255) DEFAULT NULL,
  `status_barang` enum('dipinjam','dikembalikan','hilang','rusak','pending') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `borrow`
--

INSERT INTO `borrow` (`id_peminjaman`, `id_peminjam`, `id_admin`, `kode_barang`, `jumlah_pinjam`, `kondisi_barang`, `tgl_peminjaman`, `tgl_pinjam`, `tgl_kembali`, `dl_kembali`, `foto_pengembalian`, `status_barang`, `created_at`) VALUES
(1, 1, 1, 'BRG-002', 1, 'rusak ringan', '2025-11-17', '2025-11-17', '2025-11-17', '2025-11-25', NULL, 'dikembalikan', '2025-11-17 14:37:16'),
(2, 1, 1, 'BRG-003', 3, 'baik', '2025-11-17', '2025-11-17', '2025-11-30', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 15:38:37'),
(3, 1, 1, 'BRG-001', 5, 'baik', '2025-11-17', '2025-11-17', '2025-11-30', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 15:45:44'),
(4, 2, 1, 'BRG-002', 8, 'baik', '2025-11-17', '2025-11-17', '2025-11-17', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 15:48:13'),
(5, 2, 1, 'BRG-002', 3, 'baik', '2025-11-17', '2025-11-17', '2025-11-30', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 15:50:34'),
(6, 2, 1, 'BRG-005', 40, 'baik', '2025-11-17', '2025-11-17', '2025-11-30', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 15:50:52'),
(7, 3, 1, 'BRG-005', 5, 'baik', '2025-11-17', '2025-11-17', '2025-11-18', '2025-11-24', NULL, 'dikembalikan', '2025-11-17 16:29:34'),
(8, 3, 1, 'PGSD-004', 2, 'baik', '2025-11-18', '2025-11-18', '2025-11-18', '2025-11-25', NULL, 'dikembalikan', '2025-11-17 23:09:09'),
(9, 3, 1, 'PSTI-002', 10, 'baik', '2025-11-18', '2025-11-18', '2025-11-18', '2025-11-25', NULL, 'dikembalikan', '2025-11-17 23:15:01'),
(10, 3, 1, 'PSTI-003', 4, 'baik', '2025-11-18', '2025-11-18', '2025-11-30', '2025-11-25', NULL, 'dikembalikan', '2025-11-17 23:20:16'),
(11, 3, 1, 'PSTI-003', 1, 'hilang', '2025-11-18', '2025-11-18', '2025-11-18', '2025-11-25', NULL, 'dikembalikan', '2025-11-18 02:45:06'),
(12, 3, 1, 'PGSD-001', 4, 'hilang', '2025-11-18', '2025-11-18', '2025-11-18', '2025-11-25', NULL, 'dikembalikan', '2025-11-18 02:45:16'),
(14, 3, 1, 'BRG-002', 3, NULL, '2025-11-18', '2025-11-20', NULL, '2025-11-25', NULL, 'dipinjam', '2025-11-18 03:59:10'),
(16, 1, 1, 'PSTI-001', 5, 'rusak berat', '2025-12-06', '2025-12-06', '2025-12-06', '2025-12-13', NULL, 'dikembalikan', '2025-12-05 20:29:32'),
(17, 1, 1, 'PSTI-002', 15, 'rusak berat', '2025-12-06', '2025-12-06', '2025-12-06', '2025-12-13', NULL, 'dikembalikan', '2025-12-05 21:32:17'),
(18, 1, 1, 'PSTI-003', 3, 'baik', '2025-12-06', '2025-12-06', '2025-12-07', '2025-12-13', NULL, 'dikembalikan', '2025-12-06 12:47:02'),
(19, 1, 1, 'PSTI-003', 3, 'baik', '2025-12-07', '2025-12-07', '2025-12-07', '2025-12-14', NULL, 'dikembalikan', '2025-12-07 04:51:46'),
(20, 1, 1, 'BRG-003', 1, NULL, '2025-12-07', '2025-12-07', NULL, '2025-12-14', NULL, 'dipinjam', '2025-12-07 06:59:48'),
(21, 1, 1, 'PSTI-001', 5, NULL, '2025-12-07', '2025-12-07', NULL, '2025-12-24', NULL, 'dipinjam', '2025-12-07 16:12:54'),
(22, 1, 1, 'PSTI-003', 2, NULL, '2025-12-10', '2025-12-10', NULL, '2025-12-17', NULL, 'dipinjam', '2025-12-10 15:58:17');

-- --------------------------------------------------------

--
-- Table structure for table `instansi`
--

CREATE TABLE `instansi` (
  `id_instansi` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `nama_instansi` varchar(100) NOT NULL,
  `kategori` enum('LEMBAGA','BEM','HIMPUNAN','UKM') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `instansi`
--

INSERT INTO `instansi` (`id_instansi`, `id_user`, `nama_instansi`, `kategori`) VALUES
(1, 4, 'Badan Eksekutif Mahasiswa FIK', 'BEM'),
(2, 8, 'HIMA PGSD', 'HIMPUNAN'),
(3, 9, 'HIMA UDI', 'HIMPUNAN'),
(4, 10, 'HIMA PSTI', 'HIMPUNAN'),
(5, 11, 'HMST', 'HIMPUNAN'),
(6, 12, 'HIMATRONIKA-AI', 'HIMPUNAN');

-- --------------------------------------------------------

--
-- Table structure for table `lapor`
--

CREATE TABLE `lapor` (
  `id_laporan` int(11) NOT NULL,
  `no_laporan` varchar(50) NOT NULL,
  `id_peminjaman` int(11) NOT NULL,
  `kode_barang` varchar(50) NOT NULL,
  `status` enum('diproses','selesai','ditolak') DEFAULT 'diproses',
  `tgl_laporan` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lapor`
--

INSERT INTO `lapor` (`id_laporan`, `no_laporan`, `id_peminjaman`, `kode_barang`, `status`, `tgl_laporan`, `created_at`, `keterangan`) VALUES
(1, 'LAP-00001', 7, 'BRG-005', 'selesai', '2025-11-18', '2025-11-17 17:20:16', NULL),
(2, 'LAP-00002', 7, 'BRG-005', 'selesai', '2025-11-18', '2025-11-17 17:21:12', NULL),
(3, 'LAP-00003', 11, 'PSTI-003', 'selesai', '2025-11-18', '2025-11-18 02:49:13', NULL),
(4, 'LAP-00004', 12, 'PGSD-001', 'selesai', '2025-11-18', '2025-11-18 04:04:10', NULL),
(5, 'LAP-00005', 11, 'PSTI-003', 'selesai', '2025-11-18', '2025-11-18 04:06:57', NULL),
(6, 'LAP-00006', 20, 'BRG-003', 'ditolak', '2025-12-08', '2025-12-07 17:41:33', NULL),
(7, 'LAP-00007', 20, 'BRG-003', 'selesai', '2025-12-08', '2025-12-08 14:40:11', NULL),
(8, 'LAP-00008', 21, 'PSTI-001', 'selesai', '2025-12-10', '2025-12-10 15:58:56', NULL),
(9, 'LAP-00009', 21, 'PSTI-001', 'selesai', '2025-12-10', '2025-12-10 16:35:20', NULL),
(10, 'LAP-00010', 22, 'PSTI-003', 'selesai', '2025-12-11', '2025-12-10 17:10:01', 'manuk akal\n'),
(11, 'LAP-00011', 21, 'PSTI-001', 'selesai', '2025-12-11', '2025-12-10 17:13:03', 'laptopnya rusak bjir\n'),
(12, 'LAP-00012', 22, 'PSTI-003', 'selesai', '2025-12-11', '2025-12-10 17:17:36', 'tes');

-- --------------------------------------------------------

--
-- Table structure for table `log_activity`
--

CREATE TABLE `log_activity` (
  `id_log` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `aktifitas` varchar(100) NOT NULL,
  `user_role` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_activity`
--

INSERT INTO `log_activity` (`id_log`, `username`, `keterangan`, `aktifitas`, `user_role`, `created_at`) VALUES
(1, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-15 22:36:37'),
(2, 'admin', 'Menambah barang baru: Proyektor Epson', 'CREATE_BARANG', 'admin', '2025-11-15 22:36:37'),
(3, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 14:31:01'),
(4, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 14:36:27'),
(5, 'budi123', 'Menambah peminjaman: Laptop Dell Latitude - 1 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 14:37:17'),
(6, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 14:41:46'),
(7, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 14:41:52'),
(8, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 14:43:16'),
(9, 'acil', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 14:44:47'),
(10, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 14:44:52'),
(11, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 14:48:16'),
(12, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 14:49:19'),
(13, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 14:54:41'),
(14, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 15:02:50'),
(15, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 15:03:36'),
(16, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:03:44'),
(17, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:13:20'),
(18, 'acil', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:13:53'),
(19, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 15:13:59'),
(20, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 15:19:58'),
(21, 'admin', 'Menyetujui peminjaman ID: 1', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 15:30:28'),
(22, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 15:30:44'),
(23, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:30:53'),
(24, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 15:33:44'),
(25, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:34:03'),
(26, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:36:40'),
(27, 'acil', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:37:02'),
(28, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:38:29'),
(29, 'budi123', 'Menambah peminjaman: Kamera Canon EOS - 3 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 15:38:40'),
(30, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:39:20'),
(31, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:39:26'),
(32, 'andi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:40:25'),
(33, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:42:51'),
(34, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:42:54'),
(35, 'siti456', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:43:01'),
(36, 'siti456', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:43:05'),
(37, 'siti456', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:43:22'),
(38, 'siti456', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:44:19'),
(39, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:44:24'),
(40, 'budi123', 'Mengembalikan barang: Laptop Dell Latitude', 'RETURN_BARANG', 'peminjam', '2025-11-17 15:44:51'),
(41, 'budi123', 'Menambah peminjaman: Proyektor Epson - 5 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 15:45:45'),
(42, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:45:47'),
(43, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 15:45:52'),
(44, 'admin', 'Menyetujui peminjaman ID: 3', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 15:45:58'),
(45, 'admin', 'Menyetujui peminjaman ID: 2', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 15:46:00'),
(46, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 15:46:24'),
(47, 'siti456', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:46:35'),
(48, 'siti456', 'Mengubah barang: BRG-003 - Kamera Canon EOS', 'UPDATE_BARANG', 'peminjam', '2025-11-17 15:47:27'),
(49, 'siti456', 'Menambah peminjaman: Laptop Dell Latitude - 8 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 15:48:14'),
(50, 'siti456', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 15:48:44'),
(51, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 15:48:50'),
(52, 'admin', 'Menyetujui peminjaman ID: 4', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 15:49:20'),
(53, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-17 15:49:53'),
(54, 'siti456', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 15:49:59'),
(55, 'siti456', 'Mengembalikan barang: Laptop Dell Latitude', 'RETURN_BARANG', 'peminjam', '2025-11-17 15:50:18'),
(56, 'siti456', 'Menambah peminjaman: Laptop Dell Latitude - 3 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 15:50:35'),
(57, 'siti456', 'Menambah peminjaman: Meja Lipat - 40 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 15:50:52'),
(58, 'acil', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 16:19:51'),
(59, 'acil', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 16:29:20'),
(60, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 16:29:26'),
(61, 'andi123', 'Menambah peminjaman: Meja Lipat - 5 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 16:29:35'),
(62, 'siti456', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 16:29:40'),
(63, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 16:29:54'),
(64, 'admin', 'Menyetujui peminjaman ID: 6', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 16:30:07'),
(65, 'admin', 'Menyetujui peminjaman ID: 7', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 16:30:19'),
(66, 'andi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 16:30:58'),
(67, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 16:31:07'),
(68, 'andi123', 'Menambah laporan: LAP-00001 - Meja Lipat', 'CREATE_LAPORAN', 'peminjam', '2025-11-17 17:20:17'),
(69, 'admin', 'menyelesaikan laporan: LAP-00001', 'UPDATE_LAPORAN', 'admin', '2025-11-17 17:20:40'),
(70, 'admin', 'menyelesaikan laporan: LAP-00001', 'UPDATE_LAPORAN', 'admin', '2025-11-17 17:20:52'),
(71, 'admin', 'menyelesaikan laporan: LAP-00001', 'UPDATE_LAPORAN', 'admin', '2025-11-17 17:20:55'),
(72, 'admin', 'menolak laporan: LAP-00001', 'UPDATE_LAPORAN', 'admin', '2025-11-17 17:21:00'),
(73, 'admin', 'menyelesaikan laporan: LAP-00001', 'UPDATE_LAPORAN', 'admin', '2025-11-17 17:21:03'),
(74, 'andi123', 'Menambah laporan: LAP-00002 - Meja Lipat', 'CREATE_LAPORAN', 'peminjam', '2025-11-17 17:21:13'),
(75, 'andi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-17 17:21:18'),
(76, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 17:21:44'),
(77, 'andi123', 'Mengembalikan barang: Meja Lipat', 'RETURN_BARANG', 'peminjam', '2025-11-17 17:22:11'),
(78, 'bem_fik', 'Login ke sistem', 'LOGIN', 'instansi', '2025-11-17 18:19:29'),
(79, 'bem_fik', 'Logout dari sistem', 'LOGOUT', 'instansi', '2025-11-17 18:21:16'),
(80, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-17 23:07:51'),
(81, 'andi123', 'Menambah peminjaman: Curug Bidadari - 2 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 23:09:11'),
(82, 'hima_psti', 'Login ke sistem', 'LOGIN', 'instansi', '2025-11-17 23:11:28'),
(83, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 23:12:21'),
(84, 'admin', 'Menyetujui peminjaman ID: 8', 'APPROVE_BORROW', 'admin', '2025-11-17 23:13:09'),
(85, 'andi123', 'Menambah peminjaman: Arduino Kit - 10 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 23:15:03'),
(86, 'admin', 'Menyetujui peminjaman ID: 9', 'APPROVE_BORROW', 'admin', '2025-11-17 23:15:28'),
(87, 'hima_psti', 'Menambah barang: PSTI-003 - bola', 'CREATE_BARANG', 'instansi', '2025-11-17 23:17:05'),
(88, 'admin', 'Menyetujui peminjaman ID: 5', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-17 23:18:19'),
(89, 'andi123', 'Menambah peminjaman: bola - 4 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-17 23:20:18'),
(90, 'andi123', 'Mengembalikan barang: Arduino Kit', 'RETURN_BARANG', 'peminjam', '2025-11-17 23:21:34'),
(91, 'andi123', 'Mengembalikan barang: Curug Bidadari', 'RETURN_BARANG', 'peminjam', '2025-11-17 23:21:37'),
(92, 'hima_psti', 'Logout dari sistem', 'LOGOUT', 'instansi', '2025-11-17 23:22:00'),
(93, 'hima_psti', 'Login ke sistem', 'LOGIN', 'instansi', '2025-11-17 23:22:09'),
(94, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 23:40:03'),
(95, 'hima_psti', 'Login ke sistem', 'LOGIN', 'instansi', '2025-11-17 23:40:27'),
(96, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-17 23:41:16'),
(97, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-11-18 00:09:04'),
(98, 'hima_psti', 'Login ke sistem', 'LOGIN', 'instansi', '2025-11-18 00:09:15'),
(99, 'hima_psti', 'Logout dari sistem', 'LOGOUT', 'instansi', '2025-11-18 00:09:30'),
(100, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-18 00:09:39'),
(101, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-18 02:44:56'),
(102, 'andi123', 'Menambah peminjaman: bola - 1 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-18 02:45:07'),
(103, 'andi123', 'Menambah peminjaman: KapiBaro - 4 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-18 02:45:17'),
(104, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-18 02:45:45'),
(105, 'admin', 'Menyetujui peminjaman ID: 12', 'APPROVE_BORROW', 'admin', '2025-11-18 02:45:54'),
(106, 'admin', 'Menyetujui peminjaman ID: 12', 'APPROVE_BORROW', 'admin', '2025-11-18 02:45:57'),
(107, 'admin', 'Menyetujui peminjaman ID: 12', 'APPROVE_BORROW', 'admin', '2025-11-18 02:45:59'),
(108, 'admin', 'Menyetujui peminjaman ID: 11', 'APPROVE_BORROW', 'admin', '2025-11-18 02:46:01'),
(109, 'admin', 'Menyetujui peminjaman ID: 10', 'APPROVE_BORROW', 'admin', '2025-11-18 02:46:04'),
(110, 'andi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-18 02:46:34'),
(111, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-18 02:46:43'),
(112, 'andi123', 'Menambah laporan: LAP-00003 - bola', 'CREATE_LAPORAN', 'peminjam', '2025-11-18 02:49:14'),
(113, 'admin', 'menyelesaikan laporan: LAP-00003', 'PROCESS_LAPORAN', 'admin', '2025-11-18 02:50:33'),
(114, 'andi123', 'Menambah peminjaman: KapiBaro - 2 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-18 02:51:51'),
(115, 'andi123', 'Menambah peminjaman: Laptop Dell Latitude - 3 unit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-11-18 03:59:26'),
(116, 'andi123', 'Menambah laporan: LAP-00004 - KapiBaro', 'CREATE_LAPORAN', 'peminjam', '2025-11-18 04:04:14'),
(117, 'andi123', 'Mengembalikan barang: KapiBaro', 'RETURN_BARANG', 'peminjam', '2025-11-18 04:05:02'),
(118, 'andi123', 'Menambah laporan: LAP-00005 - bola', 'CREATE_LAPORAN', 'peminjam', '2025-11-18 04:06:59'),
(119, 'andi123', 'Mengembalikan barang: bola', 'RETURN_BARANG', 'peminjam', '2025-11-18 04:07:30'),
(120, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-27 21:55:08'),
(121, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-27 22:52:00'),
(122, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-27 22:55:20'),
(123, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-29 22:15:29'),
(124, 'admin', 'Mengembalikan barang: Kamera Canon EOS', 'RETURN_BARANG', 'admin', '2025-11-29 22:15:47'),
(125, 'admin', 'Mengembalikan barang: Laptop Dell Latitude', 'RETURN_BARANG', 'admin', '2025-11-29 22:15:49'),
(126, 'admin', 'Mengembalikan barang: Proyektor Epson', 'RETURN_BARANG', 'admin', '2025-11-29 22:15:52'),
(127, 'admin', 'Mengembalikan barang: Meja Lipat', 'RETURN_BARANG', 'admin', '2025-11-29 22:15:54'),
(128, 'admin', 'Mengembalikan barang: bola', 'RETURN_BARANG', 'admin', '2025-11-29 22:15:55'),
(129, 'admin', 'Menyetujui peminjaman ID: 14', 'APPROVE_PEMINJAMAN', 'admin', '2025-11-29 22:16:06'),
(130, 'andi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 22:30:48'),
(131, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 22:31:43'),
(132, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 22:33:32'),
(133, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 22:41:49'),
(134, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-11-29 23:11:50'),
(135, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 23:12:20'),
(136, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 23:16:30'),
(137, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 23:42:59'),
(138, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-29 23:46:24'),
(139, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-11-29 23:57:24'),
(140, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:00:37'),
(141, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:02:37'),
(142, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:06:03'),
(143, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:07:18'),
(144, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:12:27'),
(145, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:14:12'),
(146, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:23:47'),
(147, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:27:35'),
(148, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:33:12'),
(149, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:39:43'),
(150, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:44:19'),
(151, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:46:28'),
(152, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:48:57'),
(153, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:51:02'),
(154, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:58:44'),
(155, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 00:59:32'),
(156, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:03:54'),
(157, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:09:16'),
(158, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:13:06'),
(159, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:14:38'),
(160, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:20:26'),
(161, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:22:30'),
(162, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:26:59'),
(163, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:32:27'),
(164, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-11-30 01:33:49'),
(165, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-01 12:12:41'),
(166, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 09:36:19'),
(167, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:03:41'),
(168, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:10:21'),
(169, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:13:00'),
(170, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:19:03'),
(171, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:21:08'),
(172, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:22:08'),
(173, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:26:15'),
(174, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:28:06'),
(175, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:28:55'),
(176, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:30:46'),
(177, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-02 10:33:43'),
(178, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 10:54:33'),
(179, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 10:57:00'),
(180, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 10:58:09'),
(181, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 11:03:15'),
(182, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 11:04:20'),
(183, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-03 11:07:29'),
(184, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-04 01:52:33'),
(185, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-04 03:56:48'),
(186, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-04 04:16:38'),
(187, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-04 04:17:52'),
(188, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-04 04:32:31'),
(189, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-04 04:32:40'),
(190, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 11:17:41'),
(191, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 17:28:25'),
(192, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 17:31:07'),
(193, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 17:40:32'),
(194, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 17:45:08'),
(195, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:05:07'),
(196, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 18:05:11'),
(197, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:05:17'),
(198, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:11:48'),
(199, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:12:35'),
(200, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:16:04'),
(201, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:21:42'),
(202, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:23:26'),
(203, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:25:10'),
(204, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:42:27'),
(205, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:42:30'),
(206, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:42:31'),
(207, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:43:25'),
(208, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 18:57:36'),
(209, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:03:11'),
(210, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:05:52'),
(211, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:07:41'),
(212, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:15:26'),
(213, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:23:49'),
(214, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:25:56'),
(215, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:29:18'),
(216, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:34:53'),
(217, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 19:36:02'),
(218, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 19:40:41'),
(219, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:05:40'),
(220, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:11:38'),
(221, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:14:27'),
(222, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:17:04'),
(223, 'budi123', 'Menambah peminjaman: bola', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-05 20:17:40'),
(224, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:25:59'),
(225, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 20:27:10'),
(226, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-05 20:27:17'),
(227, 'admin', 'Menyetujui peminjaman ID: 15', 'APPROVE_BORROW', 'admin', '2025-12-05 20:27:38'),
(228, 'admin', 'Menyetujui peminjaman ID: 15', 'APPROVE_BORROW', 'admin', '2025-12-05 20:27:43'),
(229, 'admin', 'Menolak peminjaman ID: 15', 'REJECT_BORROW', 'admin', '2025-12-05 20:27:47'),
(230, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-05 20:27:54'),
(231, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:28:02'),
(232, 'budi123', 'Menambah peminjaman: Laptop Programming', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-05 20:29:32'),
(233, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 20:29:43'),
(234, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-05 20:29:48'),
(235, 'admin', 'Menyetujui peminjaman ID: 16', 'APPROVE_BORROW', 'admin', '2025-12-05 20:29:59'),
(236, 'admin', 'Menyetujui peminjaman ID: 16', 'APPROVE_BORROW', 'admin', '2025-12-05 20:30:03'),
(237, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-05 20:30:15'),
(238, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:30:23'),
(239, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:35:22'),
(240, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:36:35'),
(241, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:49:01'),
(242, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:54:46'),
(243, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 20:57:18'),
(244, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 21:14:55'),
(245, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 21:15:19'),
(246, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 21:24:13'),
(247, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 21:28:07'),
(248, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-05 21:30:16'),
(249, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-05 21:30:23'),
(250, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-05 21:31:19'),
(251, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-05 21:31:55'),
(252, 'budi123', 'Menambah peminjaman: Arduino Kit', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-05 21:32:17'),
(253, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-06 11:18:36'),
(254, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-06 12:44:17'),
(255, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-06 12:44:37'),
(256, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-06 12:44:43'),
(257, 'admin', 'Menyetujui peminjaman ID: 17', 'APPROVE_BORROW', 'admin', '2025-12-06 12:44:56'),
(258, 'admin', 'Menyetujui peminjaman ID: 17', 'APPROVE_BORROW', 'admin', '2025-12-06 12:45:13'),
(259, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-06 12:45:16'),
(260, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-06 12:45:21'),
(261, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-06 12:45:33'),
(262, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-06 12:45:39'),
(263, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-06 12:46:13'),
(264, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-06 12:46:19'),
(265, 'budi123', 'Menambah peminjaman: bola', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-06 12:47:02'),
(266, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-06 12:47:09'),
(267, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-06 12:47:27'),
(268, 'admin', 'Menyetujui peminjaman ID: 18', 'APPROVE_BORROW', 'admin', '2025-12-06 12:48:06'),
(269, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 02:55:51'),
(270, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 03:12:32'),
(271, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 03:23:22'),
(272, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:14:48'),
(273, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:48:05'),
(274, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 04:49:01'),
(275, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-07 04:49:05'),
(276, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-07 04:50:24'),
(277, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:50:29'),
(278, 'budi123', 'Menambah peminjaman: bola', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-07 04:51:46'),
(279, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 04:51:49'),
(280, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-07 04:51:53'),
(281, 'admin', 'Menyetujui peminjaman ID: 19', 'APPROVE_BORROW', 'admin', '2025-12-07 04:52:06'),
(282, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-07 04:52:10'),
(283, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:52:18'),
(284, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 04:53:17'),
(285, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:53:22'),
(286, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 04:53:31'),
(287, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 04:56:51'),
(288, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 05:00:11'),
(289, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 05:00:17'),
(290, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 05:37:16'),
(291, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 05:48:00'),
(292, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 06:59:30'),
(293, 'budi123', 'Menambah peminjaman: Kamera Canon EOS', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-07 06:59:48'),
(294, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 11:21:34'),
(295, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 11:43:41'),
(296, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 11:48:19'),
(297, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 11:53:30'),
(298, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 11:57:27'),
(299, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 15:58:19'),
(300, 'budi123', 'Menambah peminjaman: Laptop Programming', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-07 16:12:54'),
(301, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-07 16:13:29'),
(302, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-07 16:13:47'),
(303, 'admin', 'Menyetujui peminjaman ID: 21', 'APPROVE_BORROW', 'admin', '2025-12-07 16:15:17'),
(304, 'admin', 'Menyetujui peminjaman ID: 20', 'APPROVE_BORROW', 'admin', '2025-12-07 16:15:20'),
(305, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-07 16:18:23'),
(306, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 16:18:32'),
(307, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-07 17:40:58'),
(308, 'budi123', 'Menambah Laporan: LAP-00006', 'CREATE_LAPORAN', 'peminjam', '2025-12-07 17:41:35'),
(309, 'budi123', 'Menambah Laporan: LAP-00007', 'CREATE_LAPORAN', 'peminjam', '2025-12-08 14:40:13'),
(310, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 15:57:42'),
(311, 'budi123', 'Menambah peminjaman: Bola Basket', 'CREATE_PEMINJAMAN', 'peminjam', '2025-12-10 15:58:17'),
(312, 'budi123', 'Menambah Laporan: LAP-00008', 'CREATE_LAPORAN', 'peminjam', '2025-12-10 15:58:58'),
(313, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 15:59:02'),
(314, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 15:59:09'),
(315, 'admin', 'Menyetujui peminjaman ID: 22', 'APPROVE_BORROW', 'admin', '2025-12-10 15:59:25'),
(316, 'admin', 'Menyetujui peminjaman ID: 13', 'APPROVE_BORROW', 'admin', '2025-12-10 16:01:48'),
(317, 'admin', 'Menolak peminjaman ID: 13', 'REJECT_BORROW', 'admin', '2025-12-10 16:01:52'),
(318, 'admin', 'menyelesaikan laporan: LAP-00008', 'PROCESS_LAPORAN', 'admin', '2025-12-10 16:02:17'),
(319, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 16:02:29'),
(320, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 16:17:30'),
(321, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 16:25:46'),
(322, 'admin', 'Menyelesaikan Laporan: LAP-00002', 'PROCESS_LAPORAN', 'admin', '2025-12-10 16:26:00'),
(323, 'admin', 'Menyelesaikan Laporan: LAP-00005', 'PROCESS_LAPORAN', 'admin', '2025-12-10 16:26:09'),
(324, 'admin', 'Menyelesaikan Laporan: LAP-00004', 'PROCESS_LAPORAN', 'admin', '2025-12-10 16:26:20'),
(325, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 16:34:45'),
(326, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 16:34:58'),
(327, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 16:35:06'),
(328, 'budi123', 'Menambah Laporan: LAP-00009', 'CREATE_LAPORAN', 'peminjam', '2025-12-10 16:35:21'),
(329, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 16:35:23'),
(330, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 16:35:29'),
(331, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 16:35:35'),
(332, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 16:35:40'),
(333, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 17:08:52'),
(334, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 17:09:50'),
(335, 'budi123', 'Menambah Laporan: LAP-00010', 'CREATE_LAPORAN', 'peminjam', '2025-12-10 17:10:02'),
(336, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 17:10:05'),
(337, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:10:10'),
(338, 'admin', 'Menyelesaikan Laporan: LAP-00010', 'PROCESS_LAPORAN', 'admin', '2025-12-10 17:10:54'),
(339, 'admin', 'Menyelesaikan Laporan: LAP-00009', 'PROCESS_LAPORAN', 'admin', '2025-12-10 17:11:02'),
(340, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 17:12:46'),
(341, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 17:12:51'),
(342, 'budi123', 'Menambah Laporan: LAP-00011', 'CREATE_LAPORAN', 'peminjam', '2025-12-10 17:13:04'),
(343, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 17:13:06'),
(344, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 17:13:11'),
(345, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 17:13:13'),
(346, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:13:18'),
(347, 'admin', 'Menyelesaikan Laporan: LAP-00011', 'PROCESS_LAPORAN', 'admin', '2025-12-10 17:13:23'),
(348, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:16:59'),
(349, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 17:17:09'),
(350, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 17:17:18'),
(351, 'budi123', 'Menambah Laporan: LAP-00012', 'CREATE_LAPORAN', 'peminjam', '2025-12-10 17:17:37'),
(352, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 17:17:38'),
(353, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:17:43'),
(354, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:24:14'),
(355, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:27:34'),
(356, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:28:11'),
(357, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:30:38'),
(358, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:33:05'),
(359, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:35:24'),
(360, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:36:09'),
(361, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 17:46:34'),
(362, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:53:39'),
(363, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 17:55:18'),
(364, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:09:26'),
(365, 'admin', 'Reset password user: budi123', 'RESET_PASSWORD', 'admin', '2025-12-10 18:10:08'),
(366, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 18:10:14'),
(367, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:10:19'),
(368, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 18:10:25'),
(369, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:10:30'),
(370, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:18:49'),
(371, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:32:11'),
(372, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:33:14'),
(373, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:33:24'),
(374, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:33:42'),
(375, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:35:35'),
(376, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:35:37'),
(377, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:37:40'),
(378, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:39:07'),
(379, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:39:09'),
(380, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:40:35'),
(381, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:53:02'),
(382, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 18:53:33'),
(383, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 18:58:45'),
(384, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 19:00:46'),
(385, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 19:00:54'),
(386, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 19:01:02'),
(387, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 19:11:32'),
(388, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 19:18:05'),
(389, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 19:19:31'),
(390, 'admin', 'Menyelesaikan Laporan: LAP-00012', 'PROCESS_LAPORAN', 'admin', '2025-12-10 19:55:25'),
(391, 'admin', 'Logout dari sistem', 'LOGOUT', 'admin', '2025-12-10 19:55:33'),
(392, 'budi123', 'Login ke sistem', 'LOGIN', 'peminjam', '2025-12-10 19:55:40'),
(393, 'budi123', 'Logout dari sistem', 'LOGOUT', 'peminjam', '2025-12-10 19:57:00'),
(394, 'admin', 'Login ke sistem', 'LOGIN', 'admin', '2025-12-10 19:57:06');

-- --------------------------------------------------------

--
-- Table structure for table `peminjam`
--

CREATE TABLE `peminjam` (
  `id_peminjam` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `no_telepon` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `peminjam`
--

INSERT INTO `peminjam` (`id_peminjam`, `id_user`, `no_telepon`) VALUES
(1, 2, '081234567890'),
(2, 3, '082345678901'),
(3, 7, '081298765432');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `role` enum('admin','peminjam','instansi') NOT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `username`, `password`, `nama`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 'admin', '123456', 'Administrator', 'admin', 'aktif', '2025-11-15 22:36:36', '2025-11-17 14:44:40'),
(2, 'budi123', '$2a$10$gReGFygnPnLRSnV9i8z8f.saK2TFS1MOj22A36l4FrJmbuobvy1VS', 'Budi Santoso', 'peminjam', 'aktif', '2025-11-15 22:36:36', '2025-12-10 18:10:07'),
(3, 'siti456', '123456', 'Siti Nurhaliza', 'peminjam', 'aktif', '2025-11-15 22:36:36', '2025-11-17 15:40:17'),
(4, 'bem_fik', '123456', 'BEM FIK', 'instansi', 'aktif', '2025-11-15 22:36:36', '2025-11-17 18:19:15'),
(7, 'andi123', '123456', 'Andi Nugraha', 'peminjam', 'aktif', '2025-11-17 16:28:54', '2025-11-17 16:28:54'),
(8, 'hima_pgsd', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'HIMA PGSD', 'instansi', 'aktif', '2025-11-17 22:09:21', '2025-11-17 22:09:21'),
(9, 'hima_udi', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'HIMA UDI', 'instansi', 'aktif', '2025-11-17 22:09:21', '2025-11-17 22:09:21'),
(10, 'hima_psti', '123456', 'HIMA PSTI', 'instansi', 'aktif', '2025-11-17 22:09:21', '2025-11-17 23:11:00'),
(11, 'hmst', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'HMST', 'instansi', 'aktif', '2025-11-17 22:09:21', '2025-11-17 22:09:21'),
(12, 'himatronika', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'HIMATRONIKA-AI', 'instansi', 'aktif', '2025-11-17 22:09:21', '2025-11-17 22:09:21');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang_with_owner`
-- (See below for the actual view)
--
CREATE TABLE `v_barang_with_owner` (
`id_barang` int(11)
,`id_instansi` int(11)
,`kode_barang` varchar(50)
,`nama_barang` varchar(100)
,`lokasi_barang` varchar(100)
,`jumlah_total` int(11)
,`jumlah_tersedia` int(11)
,`deskripsi` text
,`kondisi_barang` enum('baik','rusak ringan','rusak berat')
,`status` enum('tersedia','dipinjam','rusak','hilang')
,`foto` varchar(255)
,`created_at` timestamp
,`updated_at` timestamp
,`nama_pemilik` varchar(100)
,`nama_lengkap` varchar(203)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_peminjaman_aktif`
-- (See below for the actual view)
--
CREATE TABLE `v_peminjaman_aktif` (
`id_peminjaman` int(11)
,`nama_peminjam` varchar(100)
,`no_telepon` varchar(15)
,`kode_barang` varchar(50)
,`nama_barang` varchar(100)
,`jumlah_pinjam` int(11)
,`tgl_pinjam` date
,`dl_kembali` date
,`sisa_hari` int(7)
,`status_barang` enum('dipinjam','dikembalikan','hilang','rusak','pending')
);

-- --------------------------------------------------------

--
-- Structure for view `v_barang_with_owner`
--
DROP TABLE IF EXISTS `v_barang_with_owner`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang_with_owner`  AS SELECT `b`.`id_barang` AS `id_barang`, `b`.`id_instansi` AS `id_instansi`, `b`.`kode_barang` AS `kode_barang`, `b`.`nama_barang` AS `nama_barang`, `b`.`lokasi_barang` AS `lokasi_barang`, `b`.`jumlah_total` AS `jumlah_total`, `b`.`jumlah_tersedia` AS `jumlah_tersedia`, `b`.`deskripsi` AS `deskripsi`, `b`.`kondisi_barang` AS `kondisi_barang`, `b`.`status` AS `status`, `b`.`foto` AS `foto`, `b`.`created_at` AS `created_at`, `b`.`updated_at` AS `updated_at`, `i`.`nama_instansi` AS `nama_pemilik`, concat(`b`.`nama_barang`,' (',coalesce(`i`.`nama_instansi`,'Umum'),')') AS `nama_lengkap` FROM (`barang` `b` left join `instansi` `i` on(`b`.`id_instansi` = `i`.`id_instansi`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_peminjaman_aktif`
--
DROP TABLE IF EXISTS `v_peminjaman_aktif`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_peminjaman_aktif`  AS SELECT `b`.`id_peminjaman` AS `id_peminjaman`, `u`.`nama` AS `nama_peminjam`, `p`.`no_telepon` AS `no_telepon`, `br`.`kode_barang` AS `kode_barang`, `br`.`nama_barang` AS `nama_barang`, `b`.`jumlah_pinjam` AS `jumlah_pinjam`, `b`.`tgl_pinjam` AS `tgl_pinjam`, `b`.`dl_kembali` AS `dl_kembali`, to_days(`b`.`dl_kembali`) - to_days(curdate()) AS `sisa_hari`, `b`.`status_barang` AS `status_barang` FROM (((`borrow` `b` join `peminjam` `p` on(`b`.`id_peminjam` = `p`.`id_peminjam`)) join `user` `u` on(`p`.`id_user` = `u`.`id_user`)) join `barang` `br` on(`b`.`kode_barang` = `br`.`kode_barang`)) WHERE `b`.`status_barang` = 'dipinjam' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_admin`),
  ADD UNIQUE KEY `id_user` (`id_user`);

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id_barang`),
  ADD UNIQUE KEY `kode_barang` (`kode_barang`),
  ADD KEY `idx_barang_status` (`status`),
  ADD KEY `idx_barang_instansi` (`id_instansi`);

--
-- Indexes for table `borrow`
--
ALTER TABLE `borrow`
  ADD PRIMARY KEY (`id_peminjaman`),
  ADD KEY `id_peminjam` (`id_peminjam`),
  ADD KEY `id_admin` (`id_admin`),
  ADD KEY `kode_barang` (`kode_barang`),
  ADD KEY `idx_borrow_status` (`status_barang`);

--
-- Indexes for table `instansi`
--
ALTER TABLE `instansi`
  ADD PRIMARY KEY (`id_instansi`),
  ADD UNIQUE KEY `id_user` (`id_user`);

--
-- Indexes for table `lapor`
--
ALTER TABLE `lapor`
  ADD PRIMARY KEY (`id_laporan`),
  ADD UNIQUE KEY `no_laporan` (`no_laporan`),
  ADD KEY `id_peminjaman` (`id_peminjaman`),
  ADD KEY `kode_barang` (`kode_barang`);

--
-- Indexes for table `log_activity`
--
ALTER TABLE `log_activity`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_log_username` (`username`);

--
-- Indexes for table `peminjam`
--
ALTER TABLE `peminjam`
  ADD PRIMARY KEY (`id_peminjam`),
  ADD UNIQUE KEY `id_user` (`id_user`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_user_role` (`role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `barang`
--
ALTER TABLE `barang`
  MODIFY `id_barang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `borrow`
--
ALTER TABLE `borrow`
  MODIFY `id_peminjaman` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `instansi`
--
ALTER TABLE `instansi`
  MODIFY `id_instansi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `lapor`
--
ALTER TABLE `lapor`
  MODIFY `id_laporan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `log_activity`
--
ALTER TABLE `log_activity`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=395;

--
-- AUTO_INCREMENT for table `peminjam`
--
ALTER TABLE `peminjam`
  MODIFY `id_peminjam` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
