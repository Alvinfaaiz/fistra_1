// lib/widgets/info_dialog.dart (Nama file bisa disesuaikan)
import 'package:flutter/material.dart';

Future<void> showAppInfoDialog({
  required BuildContext context,
  required VoidCallback onMengerti,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEB3B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
              const SizedBox(height: 24.0),

              // Menggunakan helper widget yang dimodifikasi
              _buildInfoTextItem(
                // Menggunakan helper baru atau yang dimodifikasi
                index: '1.',
                text:
                    'Demi kenyamanan bersama kami berharap pengguna setia FISTRA tetap menggunakan bahasa yang sopan dan tidak mengandung SARA.',
              ),
              const SizedBox(height: 12.0),
              _buildInfoTextItem(
                index: '2.',
                text:
                    'Admin hanya akan menjawab pada saat jam kerja mulai dari hari senin-sabtu pada pukul 08:00 WIB - 16:30 WIB, lebih dari itu Kami akan menjawabnya di hari berikutnya.',
              ),
              const SizedBox(height: 12.0),
              // Untuk item ke-3, kita tetap menggunakan RichText karena ada format bold pada nomor telepon
              _buildInfoRichTextItem(
                // Helper khusus untuk RichText
                context: dialogContext, // Perlu context untuk DefaultTextStyle
                index: '3.',
                textSpans: [
                  const TextSpan(
                    text:
                        'Jika pesan anda tidak dibalas dalam waktu lebih dari 4 hari, silahkan hubungi melalui panggilan suara kepada nomor ini ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  const TextSpan(
                    text: '+6281243202344',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' (ADMIN PUSAT)'),
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
        actions: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onMengerti();
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Helper widget untuk item info dengan teks biasa
Widget _buildInfoTextItem({required String index, required String text}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        index,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black.withAlpha(191),
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

// Helper widget untuk item info dengan RichText (untuk poin ke-3)
Widget _buildInfoRichTextItem({
  required BuildContext context,
  required String index,
  required List<TextSpan> textSpans,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        index,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 14.0,
              color: Colors.black.withAlpha(191),
              height: 1.4,
            ),
            children: textSpans,
          ),
        ),
      ),
    ],
  );
}
