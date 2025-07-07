import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Inisialisasi Firebase Admin SDK, agar fungsi ini punya akses ke seluruh Firebase
admin.initializeApp();
const db = admin.firestore();

// Ini adalah fungsi yang akan dipanggil oleh aplikasi Flutter
// region("asia-southeast2") berarti fungsi ini akan dijalankan di server Jakarta (lebih cepat)
export const processPayment = functions.region("asia-southeast2").https.onCall(async (data, context) => {
  // 1. Keamanan: Cek apakah pengguna yang memanggil fungsi ini sudah login
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Anda harus login untuk membayar.");
  }

  const userId = context.auth.uid; // ID pengguna yang sedang login
  const amountToPay = Number(data.amount); // Jumlah uang dari aplikasi Flutter

  // Validasi input sederhana
  if (!amountToPay || amountToPay <= 0) {
    throw new functions.https.HttpsError("invalid-argument", "Jumlah pembayaran tidak valid.");
  }

  try {
    // Menggunakan 'transaction' adalah cara paling aman untuk operasi uang
    // Jika salah satu langkah gagal, semua langkah akan dibatalkan (saldo tidak jadi berkurang)
    const transactionResult = await db.runTransaction(async (transaction) => {
      const userRef = db.collection("users").doc(userId);
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Data pengguna tidak ditemukan.");
      }

      // 2. Cek Saldo Pengguna
      const currentBalance = Number(userDoc.data()?.balance) || 0;
      if (currentBalance < amountToPay) {
        throw new functions.https.HttpsError("failed-precondition", "Saldo tidak mencukupi.");
      }

      // 3. JIKA SALDO CUKUP: Kurangi Saldo
      const newBalance = currentBalance - amountToPay;
      transaction.update(userRef, { balance: newBalance });

      // 4. Catat Transaksi ini di koleksi 'transactions'
      const transactionRef = db.collection("transactions").doc(); // Buat dokumen baru
      transaction.set(transactionRef, {
        userId: userId,
        amount: amountToPay,
        status: "success",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        // Anda bisa tambahkan data lain di sini, misal: merchantId: data.merchantId
      });

      return { newBalance: newBalance }; // Mengembalikan saldo baru jika sukses
    });

    // 5. Kembalikan pesan sukses ke aplikasi Flutter
    return {
      status: "success",
      message: `Pembayaran berhasil! Saldo baru Anda: ${transactionResult.newBalance}`,
    };
  } catch (error) {
    console.error("Payment failed for user:", userId, error);
    // Mengirim kembali error yang jelas ke aplikasi Flutter
    if (error instanceof functions.https.HttpsError) {
      throw error;
    } else {
      throw new functions.https.HttpsError("internal", "Terjadi kesalahan pada server, silakan coba lagi.");
    }
  }
});
