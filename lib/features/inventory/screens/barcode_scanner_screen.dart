import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/colors.dart';
import 'add_item_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  String? _scannedCode;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String barcode) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
      _scannedCode = barcode;
    });

    // Show success and navigate to Add Item screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Pop scanner and push Add Item screen with barcode
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemScreen(scannedBarcode: barcode),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && _isScanning) {
                final barcode = barcodes.first.rawValue ?? '';
                if (barcode.isNotEmpty) {
                  _onBarcodeDetected(barcode);
                }
              }
            },
          ),
          // Overlay with scan area guide
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _scannedCode != null ? AppColors.success : AppColors.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _scannedCode != null
                  ? Container(
                      color: AppColors.success.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          // Instructions at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _scannedCode != null ? Icons.check_circle : Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _scannedCode != null
                        ? 'Barcode Scanned!'
                        : 'Position the barcode inside the frame',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _scannedCode ?? 'The barcode will be scanned automatically',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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
