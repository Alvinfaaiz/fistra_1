import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fistra_1/1_registration/presentation/screens/nama_lengkap.dart';

class NomorHpScreen extends StatefulWidget {
  const NomorHpScreen({super.key});

  @override
  State<NomorHpScreen> createState() => _NomorHpScreenState();
}

class _NomorHpScreenState extends State<NomorHpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _lanjut() {
    // Logika ketika tombol "Lanjut" ditekan
    // Misalnya, validasi nomor HP dan navigasi ke halaman berikutnya
    final phoneNumber = _phoneController.text;
    if (phoneNumber.isNotEmpty) {
      Navigator.pushReplacement(
        // Use pushReplacement if you don't want to go back to this page
        context,
        MaterialPageRoute(builder: (context) => NameInputPage(phoneNumber: '')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor HP gak boleh kosong!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna biru untuk tombol, sesuai gambar
    const Color buttonBlue = Color(0xFF3FA2F7); // Perkiraan warna dari gambar
    // Warna latar belakang field, sesuai gambar
    const Color fieldBackgroundColor = Color(0xFFF6F6F6); // Perkiraan warna

    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: true, // Ini adalah default dan akan membuat UI naik
      appBar: AppBar(
        // AppBar minimalis seperti di gambar (hanya waktu dan ikon status)
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white, // Untuk Android
          statusBarBrightness: Brightness.light, // Untuk iOS
        ),
        // Jika Anda ingin judul atau tombol kembali, tambahkan di sini
        // title: Text("Verifikasi Nomor HP"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Nomor HP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Hanya angka
                ],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Masukkan Nomor HP Kamu',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 18.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none, // Tidak ada border luar
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: buttonBlue.withAlpha(127),
                      width: 1.5,
                    ),
                  ),
                ),
                onFieldSubmitted:
                    (_) => _lanjut(), // Bisa juga lanjut saat enter
              ),
              const Spacer(), // Mendorong tombol ke bawah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _lanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 2, // Sedikit bayangan
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Tambahan padding bawah agar tidak terlalu mepet saat keyboard muncul
              // jika diperlukan, tergantung seberapa tinggi keyboard.
              // Biasanya `SafeArea` dan `resizeToAvoidBottomInset` sudah cukup.
              // SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 0),
            ],
          ),
        ),
      ),
    );
  }
}
