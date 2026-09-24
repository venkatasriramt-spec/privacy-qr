import 'package:flutter/material.dart';
import 'consent_screen.dart';

class PurposeScreen extends StatelessWidget {
  const PurposeScreen({super.key});

  final List<Map<String, dynamic>> purposes = const [
    {
      'id': 'library',
      'title': 'Library Access',
      'icon': Icons.local_library_rounded,
      'color': Colors.blueAccent,
    },
    {
      'id': 'gate',
      'title': 'Campus Gate Entry',
      'icon': Icons.security_rounded,
      'color': Colors.greenAccent,
    },
    {
      'id': 'lab',
      'title': 'Computer Lab',
      'icon': Icons.computer_rounded,
      'color': Colors.purpleAccent,
    },
    {
      'id': 'event',
      'title': 'College Event',
      'icon': Icons.event_rounded,
      'color': Colors.orangeAccent,
    },
    {
      'id': 'verify',
      'title': 'Verify a QR (Admin)',
      'icon': Icons.qr_code_scanner_rounded,
      'color': Colors.redAccent,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Purpose'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you accessing?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your QR will only reveal the minimum data required for this service.',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: purposes.length,
                itemBuilder: (context, index) {
                  final purpose = purposes[index];
                  return Card(
                    color: Theme.of(context).colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: purpose['color'].withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(purpose['icon'], color: purpose['color']),
                      ),
                      title: Text(
                        purpose['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        if (purpose['id'] == 'verify') {
                           // Navigate to scanner later
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsentScreen(purposeId: purpose['id'], title: purpose['title']),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
