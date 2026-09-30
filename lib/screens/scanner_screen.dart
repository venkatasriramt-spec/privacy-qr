import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  
  final String _secretKey = 'privacy_qr_demo_secret'; // Shared secret with QR generator (demo only)

  Future<void> _processQRCode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    _scannerController.stop(); // Pause scanning while processing

    final String rawData = barcodes.first.rawValue!;
    
    try {
      final Map<String, dynamic> payload = jsonDecode(rawData);
      
      // 1. Check if token contains required fields
      if (!payload.containsKey('signature') || 
          !payload.containsKey('nonce') || 
          !payload.containsKey('exp') ||
          !payload.containsKey('purpose')) {
        throw Exception('Invalid QR Format: Missing fields');
      }

      // 2. Verify Cryptographic Signature
      final providedSignature = payload['signature'];
      
      // Reconstruct payload without signature for hashing
      final Map<String, dynamic> hashPayload = Map.from(payload)..remove('signature');
      
      final keyBytes = utf8.encode(_secretKey);
      final payloadBytes = utf8.encode(jsonEncode(hashPayload));
      final hmacSha256 = Hmac(sha256, keyBytes);
      final expectedSignature = hmacSha256.convert(payloadBytes).toString();
      
      if (providedSignature != expectedSignature) {
        throw Exception('SECURITY ALERT: Signature Verification Failed! (Forged QR)');
      }

      // 3. Check Expiry
      final expTimestamp = payload['exp'] as int;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (currentTimestamp > expTimestamp) {
        throw Exception('Token Expired: This QR code is no longer valid.');
      }

      // 4. Check Replay Attack (Nonce check in Firestore)
      final nonce = payload['nonce'];
      
      final tokenRef = FirebaseFirestore.instance.collection('tokens').doc(nonce);
      
      // Use a transaction to ensure single-use atomicity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tokenDoc = await transaction.get(tokenRef);
        
        if (tokenDoc.exists) {
          throw Exception('REPLAY ALERT: This QR code has already been scanned!');
        }
        
        // Mark token as consumed
        transaction.set(tokenRef, {
          'consumedAt': FieldValue.serverTimestamp(),
          'scannedBy': FirebaseAuth.instance.currentUser?.uid,
          'purpose': payload['purpose'],
        });
      });
      
      // 5. Log the scan to Audit History
      await FirebaseFirestore.instance.collection('scans').add({
        'timestamp': FieldValue.serverTimestamp(),
        'scannedBy': FirebaseAuth.instance.currentUser?.uid,
        'purpose': payload['purpose'],
        'nonce': nonce,
      });

      // SUCCESS!
      _showResultDialog(
        title: '✅ Access Granted',
        message: 'Purpose: ${payload['purpose']}\nClaims verified securely.',
        color: Colors.green,
      );
      
    } catch (e) {
      // FAILED
      _showResultDialog(
        title: '❌ Access Denied',
        message: e.toString().replaceAll('Exception: ', ''),
        color: Colors.red,
      );
    }
  }

  void _showResultDialog({required String title, required String message, required Color color}) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _isProcessing = false;
              });
              _scannerController.start(); // Resume scanning
            },
            child: const Text('Scan Next'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Scanner'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _processQRCode,
          ),
          
          // Scanner Overlay Guide
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _isProcessing ? Colors.orange : Theme.of(context).colorScheme.primary,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            width: 250,
            height: 250,
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verifying Cryptography...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
