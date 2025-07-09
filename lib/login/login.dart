// MULAI COPY DARI SINI
import 'package:fistra_1/auth/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pastikan import ini ada

import 'package:fistra_1/1_registration/presentation/screens/nama_lengkap.dart';
import 'package:fistra_1/home/presentation/screens/home.dart';

const Color primaryColor = Color(0xFF3B97F7);
const Color textFieldBackgroundColor = Color(0xFFF2F7);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpScreen = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengirim kode OTP (Tidak diubah)
  void sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final phone = _phoneController.text.trim();

      await _authService.sendOtp(
        phone: phone,
        context: context,
        onCodeSent: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isOtpScreen = true;
            });
          }
        },
      );

      // Jika codeSent tidak terpanggil karena error, reset loading state
      if (mounted && !_isOtpScreen) {
        setState(() => _isLoading = false);
      }
    }
  }

  // =================================================================
  // == INI ADALAH FUNGSI YANG KITA UBAH (LANGKAH 2) ==
  // =================================================================
  void verifyAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String otp = _otpController.text.trim();

        // Panggil fungsi verifyOtp yang sekarang sudah pintar dan mengembalikan bool
        bool isNewUser = await _authService.verifyOtp(otp: otp);

        // Hentikan loading
        if (mounted) {
          setState(() => _isLoading = false);
        }

        // Lakukan navigasi berdasarkan hasilnya
        if (mounted) {
          if (isNewUser) {
            // Jika pengguna BARU, arahkan ke halaman input NAMA LENGKAP
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => NameInputPage(
                      phoneNumber: _phoneController.text.trim(),
                    ),
              ),
            );
          } else {
            // Jika pengguna LAMA, arahkan langsung ke halaman utama
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Jika terjadi error saat verifikasi OTP (misal: kode salah)
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Kode OTP salah.")),
          );
        }
      } catch (e) {
        // Tangani error lainnya
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text(
                  'Login FISTRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isOtpScreen
                      ? 'Masukkan kode OTP yang dikirim ke ${_phoneController.text}'
                      : 'Masukkan nomor HP untuk login atau registrasi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                if (!_isOtpScreen)
                  _buildTextFormField(
                    controller: _phoneController,
                    hintText: 'Nomor Handphone (contoh: +62812...)',
                    keyboardType: TextInputType.phone,
                  )
                else
                  _buildTextFormField(
                    controller: _otpController,
                    hintText: 'Masukkan 6 Digit Kode OTP',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),

                const SizedBox(height: 40),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed:
                          _isOtpScreen ? verifyAndLogin : sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isOtpScreen ? 'Verifikasi & Login' : 'Kirim Kode',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                const SizedBox(height: 24),

                // Tombol "Kembali" untuk mengubah nomor HP
                if (_isOtpScreen)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpScreen = false;
                        _isLoading = false;
                      });
                    },
                    child: const Text(
                      'Salah nomor? Kembali',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget tidak diubah
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hintText tidak boleh kosong';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: "", // Menyembunyikan counter di bawah field OTP
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: textFieldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
// SELESAI COPY DI SINI