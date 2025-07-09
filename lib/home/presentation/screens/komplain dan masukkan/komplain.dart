// lib/complaint_screen.dart

import 'package:fistra_1/home/presentation/screens/komplain%20dan%20masukkan/allertKomplain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'complaint_message_model.dart';
// Hapus import dialog info lama jika tidak digunakan lagi
// import 'widgets/complaint_info_dialog.dart';
// 1. Import dialog konfirmasi sidik jari

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ComplaintMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ComplaintMessage(
        id: 'user1',
        text:
            'Saya ingin memanyakan terkait kenapa ketika saya melakukan transaksi proses scanningnya lumayan lama ya?',
        timestamp: DateTime(2026, 6, 13, 10, 30),
        sender: MessageSender.user,
      ),
      ComplaintMessage(
        id: 'admin1',
        text:
            'Halo kak Ahmad, sebelumnya maaf atas ketidaknyamanan kakak dalam menggunakan produk kamu, terkait masalah yang kakak alami kemungkinan besar diakibatkan karena alat scanningnya sudah kotor dan terlalu banyak yang menghalangi cahaya scann oleh karena itu membuat mesin harus membaca lebih dari 1 kali, kurang lebih untuk akibatnya seperti itu kak, jadi tidak ada masalah untuk data sidik jari kakak semuanyamasi aman aja kok, nanti kami akan melakukan pembersihan berkala terhadap alat kami di setiap mitra',
        timestamp: DateTime(2026, 6, 25, 14, 15),
        sender: MessageSender.admin,
        senderName: 'FISTRA ADMIN',
        avatarIcon: Icons.admin_panel_settings_rounded,
      ),
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = ComplaintMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        timestamp: DateTime.now(),
        sender: MessageSender.user,
      );
      setState(() {
        _messages.add(newMessage);
      });
      _textController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // 2. Modifikasi metode untuk menampilkan dialog konfirmasi sidik jari
  void _onInfoButtonPressed() {
    showAppInfoDialog(
      context: context,
      onMengerti: () {
        // Aksi yang ingin dilakukan setelah pengguna menekan "Mengerti"
        // Misalnya, navigasi ke halaman pemindaian sidik jari atau tindakan lain.
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return DateFormat('HH:mm', 'id_ID').format(timestamp);
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Komplain & masukkan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.black,
            ), // Ikon mungkin perlu disesuaikan
            onPressed: _onInfoButtonPressed, // 3. Panggil metode baru
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ComplaintMessage message) {
    final bool isUser = message.sender == MessageSender.user;
    final CrossAxisAlignment alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final Color bubbleColor =
        isUser ? Colors.blue.shade50 : Colors.grey.shade200;
    final Color textColor = Colors.black87;

    Widget messageContent = Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  isUser ? const Radius.circular(18) : const Radius.circular(0),
              bottomRight:
                  isUser ? const Radius.circular(0) : const Radius.circular(18),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, fontSize: 15),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTimestamp(message.timestamp),
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Flexible(child: messageContent)],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                message.avatarIcon ?? Icons.person,
                color: Colors.white,
                size: 20,
              ),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        message.senderName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  messageContent,
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Berikan masukkan...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: _sendMessage,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
