import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting

class TransactionCardWidget extends StatefulWidget {
  final String cardNumber;
  final double initialBalance;
  final Color cardColor;

  const TransactionCardWidget({
    super.key,
    required this.cardNumber,
    required this.initialBalance,
    this.cardColor = Colors.blue,
  });

  @override
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {
  bool _isBalanceVisible = true;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.zero, // Control margin from parent
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        height: 180, // Adjust height as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [widget.cardColor.withAlpha(204), widget.cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // This is a simplified way to get the curved effect.
          // For a more accurate swoosh, you might need a CustomPainter or an overlay image.
          image: DecorationImage(
            image: const AssetImage(
              "assets/images/card_swoosh_overlay.png",
            ), // Create a transparent PNG with the white swoosh
            fit: BoxFit.cover,
            opacity: 0.15, // Adjust opacity
            // If you don't have a swoosh image, remove this DecorationImage
            // or use a different gradient trick
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.cardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isBalanceVisible
                            ? _formatCurrency(widget.initialBalance)
                            : 'Rp ***.***',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _toggleBalanceVisibility,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
