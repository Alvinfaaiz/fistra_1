// MULAI COPY DARI SINI
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // FUNGSI UNTUK MENGIRIM OTP (TIDAK PERLU DIUBAH)
  Future<void> sendOtp({
    required String phone,
    required BuildContext context,
    required Function onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Biarkan kosong untuk saat ini, kita handle manual
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Terjadi kesalahan')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // FUNGSI UNTUK MEMVERIFIKASI OTP (INI YANG KITA UBAH)
  // Perhatikan: Fungsi ini sekarang mengembalikan Future<bool>
  Future<bool> verifyOtp({required String otp}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User user = userCredential.user!;

      // Cek ke Firestore apakah pengguna ini sudah ada
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final doc = await userDocRef.get();

      if (!doc.exists) {
        // Jika DOKUMEN TIDAK ADA, ini adalah PENGGUNA BARU
        // Buat dokumen minimalis untuk mereka
        await userDocRef.set({
          'uid': user.uid,
          'nomorHP': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Kembalikan 'true' untuk menandakan PENGGUNA BARU
        return true;
      } else {
        // Jika DOKUMEN SUDAH ADA, ini adalah PENGGUNA LAMA
        // Kembalikan 'false' untuk menandakan PENGGUNA LAMA
        return false;
      }
    } on FirebaseAuthException {
      // Jika terjadi error, lemparkan lagi agar bisa ditangani di UI
      rethrow;
    }
  }

  // FUNGSI UNTUK MELENGKAPI DATA PROFIL (INI FUNGSI BARU)
  Future<void> completeUserProfile({
    required String namaLengkap,
    required String tanggalLahir,
  }) async {
    // Pastikan pengguna sudah login
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("Pengguna tidak login, tidak bisa melengkapi profil.");
    }

    // Gunakan UPDATE untuk melengkapi data dokumen yang sudah ada
    await _firestore.collection('users').doc(uid).update({
      'namaLengkap': namaLengkap,
      'tanggalLahir': tanggalLahir,
      'balance': 0, // Inisialisasi saldo saat data diri lengkap
    });
  }

  // Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
// SELESAI COPY DI SINI