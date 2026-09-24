import 'package:flutter/material.dart';
import 'qr_display_screen.dart';

class ConsentScreen extends StatelessWidget {
  final String purposeId;
  final String title;

  const ConsentScreen({super.key, required this.purposeId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Disclosure'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.privacy_tip_rounded, size: 64, color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              'Request for: $title',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              'Mandatory Disclosures',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              title: Text('Active Student Status'),
              dense: true,
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              title: Text('Cryptographic Token ID'),
              dense: true,
            ),
            const Divider(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QRDisplayScreen(purposeId: purposeId)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Generate Privacy QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
