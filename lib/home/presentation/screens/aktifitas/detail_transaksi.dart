// lib/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Pastikan path import ini sesuai dengan struktur folder Anda
import 'package:fistra_1/home/presentation/screens/aktifitas/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  // Helper untuk format mata uang
  String _formatCurrency(double amount, {bool withSymbol = true}) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp' : '', // Rp hanya jika diminta
      decimalDigits: 0,
    );
    return formatCurrency
        .format(amount)
        .trim(); // Trim untuk menghapus spasi jika simbol tidak ada
  }

  // Helper untuk format tanggal dan waktu
  String _formatDateTime(DateTime dateTime) {
    // "12 Mei 2026 || 21:09:49 WIB"
    final DateFormat dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final DateFormat timeFormat = DateFormat('HH:mm:ss', 'id_ID');
    return '${dateFormat.format(dateTime)} || ${timeFormat.format(dateTime)} WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // Tidak ada title di desain ini
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            // Logo FISTRA
            Image.asset(
              'assets/logo_fistra.png', // Pastikan path ini benar dan gambar ada di pubspec.yaml
              height: 40, // Sesuaikan ukuran
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika gambar tidak ditemukan
                return const Text(
                  'FISTRA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Fingerprint Scanner of Transaction',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              transaction.paymentStatusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(transaction.amount.abs()), // Amount utama
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDateTime(transaction.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Kode Transaksi : ${transaction.id}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('Penerima'),
            _buildDetailRow(transaction.recipientName),
            const Divider(height: 30),

            _buildSectionTitle('Sumber Dana'),
            if (transaction.sourceOfFundsName != null)
              _buildDetailRow(transaction.sourceOfFundsName!),
            if (transaction.sourceOfFundsAccount != null)
              _buildDetailRow(
                transaction.sourceOfFundsAccount!,
                isSubtle: true,
              ),
            const Divider(height: 30),

            _buildSectionTitle('Detail Pembayaran'),
            _buildKeyValueRow(
              'Nominal',
              _formatCurrency(transaction.amount.abs()),
            ),
            _buildKeyValueRow(
              'Biaya Transaksi',
              _formatCurrency(transaction.transactionFee),
            ),
            const Divider(height: 30, thickness: 1.5),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatCurrency(transaction.totalAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Spasi sebelum tombol
            // Pindahkan _buildActionButtons ke sini
            _buildActionButtons(context),
            const SizedBox(
              height: 20,
            ), // Tambahkan sedikit padding di bawah tombol jika diperlukan
          ],
        ),
      ),
      // Hapus bottomNavigationBar dari sini
      // bottomNavigationBar: _buildActionButtons(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String value, {bool isSubtle = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isSubtle ? Colors.black54 : Colors.black87,
            fontWeight: isSubtle ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // _buildActionButtons sekarang tidak lagi memiliki shadow atas yang khas untuk bottomNavigationBar
  // Kita bisa membiarkannya apa adanya atau menghilangkan shadow jika dirasa tidak perlu lagi
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      // Padding atas bisa dihilangkan atau disesuaikan jika sudah ada SizedBox di atasnya
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      // Jika tidak ingin ada background atau shadow khusus di sini, bisa dihilangkan
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.2),
      //       spreadRadius: 1,
      //       blurRadius: 5,
      //       offset: const Offset(0, -2), // changes position of shadow
      //     ),
      //   ],
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButton(
            context,
            icon: Icons.download_outlined,
            label: 'Download',
            onPressed: () {
              // Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tombol Download diklik!')),
              );
            },
          ),
          _actionButton(
            context,
            icon: Icons.share_outlined,
            label: 'Bagikan',
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tombol Bagikan diklik!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Agar Column tidak mengambil tinggi maksimal
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade400, // Warna dari desain
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha(76),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
