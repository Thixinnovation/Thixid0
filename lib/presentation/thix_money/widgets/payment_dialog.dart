
// lib/presentation/thix_money/widgets/payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:thix_id/presentation/thix_money/widgets/insufficient_funds_widget.dart';
import 'package:thix_id/services/wallet_service.dart';

class PaymentDialog extends StatefulWidget {
  final String merchantName;
  final double amount;
  final VoidCallback? onSuccess;

  const PaymentDialog({
    super.key,
    required this.merchantName,
    required this.amount,
    this.onSuccess,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final WalletService _walletService = WalletService();
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      await _walletService.debit(widget.amount);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paiement de ${widget.amount.toStringAsFixed(0)} FCFA effectué'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => const InsufficientFundsWidget(),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 64, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(
              widget.merchantName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0B1B3D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
