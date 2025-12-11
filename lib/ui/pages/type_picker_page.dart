import 'package:flutter/material.dart';
import 'generator_page.dart';
import 'home_page.dart' show QrType; // reuse your enum

class TypePickerPage extends StatelessWidget {
  const TypePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.picture_as_pdf, 'PDF', QrType.image),
      (Icons.image, 'Image', QrType.image),
      (Icons.text_fields, 'Text', QrType.text),
      (Icons.wifi, 'Wi-Fi', QrType.wifi),
      (Icons.link, 'Link', QrType.link),
    ];

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Choose the type for QR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: .95,
          children: [
            for (final it in items)
              _TypeCard(
                icon: it.$1, label: it.$2,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GeneratorPage(initialType: it.$3)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _TypeCard({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(.25),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: cs.onPrimaryContainer),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ]),
      ),
    );
  }
}
