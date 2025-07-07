import 'package:fistra_1/1_registration/presentation/screens/nomor_HP.dart';
import 'package:fistra_1/auth/auth_services.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3B97F7);
const Color textFieldBackgroundColor = Color(0xFFF2F2F7);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // Instance dari AuthService

  // -- PERUBAHAN 1: Ganti controller password dengan OTP --
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController =
      TextEditingController(); // Controller baru untuk OTP

  // -- PERUBAHAN 2: State untuk mengontrol tampilan UI --
  bool _isOtpScreen = false; // false = layar input HP, true = layar input OTP
  bool _isLoading = false; // Untuk menampilkan loading indicator

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose(); // Jangan lupa dispose controller baru
    super.dispose();
  }

  // -- PERUBAHAN 3: Fungsi baru untuk mengirim kode verifikasi --
  void sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final phone = _phoneController.text;

      // Panggil method dari AuthService untuk mengirim OTP
      await _authService.sendOtp(
        phone: phone, // pastikan formatnya +62...
        context: context,
        onCodeSent: () {
          // Callback ini akan dipanggil jika kode berhasil dikirim
          setState(() {
            _isLoading = false;
            _isOtpScreen = true; // Pindah ke layar input OTP
          });
        },
      );

      // Jika ada error, akan ditangani di dalam sendOtp (via SnackBar)
      // Jadi kita reset loading state di sini jika terjadi error sebelum codeSent dipanggil
      if (mounted && !_isOtpScreen) {
        setState(() => _isLoading = false);
      }
    }
  }

  // -- PERUBAHAN 4: Fungsi baru untuk verifikasi OTP dan login --
  void verifyAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.verifyOtp(otp: _otpController.text);
        // Navigasi akan di-handle oleh AuthGate setelah login berhasil
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
      // Tidak perlu set _isLoading = false di sini jika login berhasil,
      // karena halaman akan berganti.
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
                  // -- PERUBAHAN 5: Teks deskripsi yang dinamis --
                  _isOtpScreen
                      ? 'Masukkan kode OTP yang dikirim ke ${_phoneController.text}'
                      : 'Masukkan nomor HP untuk login atau registrasi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // -- PERUBAHAN 6: Tampilkan input yang sesuai state --
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
                  ),

                // -- PERUBAHAN 7: Hapus "Lupa PIN" karena tidak relevan --
                const SizedBox(height: 40),

                // -- PERUBAHAN 8: Tombol yang dinamis --
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

                // -- PERUBAHAN 9: Tombol registrasi bisa disembunyikan/dihapus --
                // karena alur OTP menangani login dan registrasi sekaligus.
                // Atau bisa dibiarkan jika alur registrasi Anda berbeda.
                // Untuk sementara, kita sembunyikan jika sudah di layar OTP.
                if (!_isOtpScreen)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NomorHpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Belum punya akun? Registrasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  // Helper widget tidak perlu diubah, hanya pemanggilannya
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hintText tidak boleh kosong';
        }
        return null;
      },
      decoration: InputDecoration(
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
