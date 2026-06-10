// lib/presentation/thix_money/thix_money_scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/payment_dialog.dart';
import '../../services/wallet_service.dart';

class ThixMoneyScanner extends StatefulWidget {
  final VoidCallback? onPaymentComplete;

  const ThixMoneyScanner({super.key, this.onPaymentComplete});

  @override
  State<ThixMoneyScanner> createState() => _ThixMoneyScannerState();
}

class _ThixMoneyScannerState extends State<ThixMoneyScanner> {
  final WalletService _walletService = WalletService();
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final String? code = capture.barcodes.first.rawValue;
    if (code != null) {
      setState(() => _isScanning = false);
      _processPayment(code);
    }
  }

  Future<void> _processPayment(String qrData) async {
    // Extraire les infos du QR (marchand, montant)
    final merchant = "Marchand THIX";
    final amount = 15000.0; // À parser du QR
    
    final result = await showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        merchantName: merchant,
        amount: amount,
        onSuccess: widget.onPaymentComplete,
      ),
    );
    
    if (result == true) {
      widget.onPaymentComplete?.call();
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _isScanning = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR code'),
        backgroundColor: const Color(0xFF0B1B3D),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 16),
                  const Text(
                    'Scannez le QR code du marchand',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Approchez le QR code de l\'appareil photo',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => cameraController.toggleTorch(),
                    icon: const Icon(Icons.flashlight_on),
                    label: const Text('Lampe torche'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
