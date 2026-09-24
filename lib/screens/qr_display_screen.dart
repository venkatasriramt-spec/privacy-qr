import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class QRDisplayScreen extends StatefulWidget {
  final String purposeId;
  const QRDisplayScreen({super.key, required this.purposeId});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  late String qrData;
  late int timeLeft;
  bool expired = false;
  
  @override
  void initState() {
    super.initState();
    _generateQRData();
    timeLeft = 60; // 60 seconds validity per requirements
    _startTimer();
  }

  void _generateQRData() {
    final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = iat + 60;
    final uuid = const Uuid().v4();
    final nonce = const Uuid().v4(); // cryptographic random nonce
    
    // Minimum mandatory claims based on purpose
    final claims = {
      'active_student': true,
      '${widget.purposeId}_eligible': true,
    };

    final payload = {
      'token_id': uuid,
      'purpose': widget.purposeId,
      'claims': claims,
      'iat': iat,
      'exp': exp,
      'nonce': nonce,
    };

    // Simulate backend signing (HMAC-SHA256)
    final key = utf8.encode('privacy_qr_demo_secret');
    final bytes = utf8.encode(jsonEncode(payload));
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    final finalToken = {
      ...payload,
      'signature': digest.toString(),
    };

    qrData = jsonEncode(finalToken);
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          _startTimer();
        } else {
          expired = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Privacy QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: expired
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_off_rounded, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text('QR Code Expired', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Dynamic credentials expire after 60s.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Generate New QR'),
                    onPressed: () {
                      setState(() {
                        expired = false;
                        timeLeft = 60;
                        _generateQRData();
                        _startTimer();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                    ),
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: timeLeft < 15 ? Colors.redAccent : Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: timeLeft < 15 ? Colors.redAccent : Colors.greenAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Valid for $timeLeft seconds',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: timeLeft < 15 ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Single-use • Service-bound • Signed', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
