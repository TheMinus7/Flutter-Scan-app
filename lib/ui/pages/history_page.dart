import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('PDF-1', 'Today 11:30'),
      ('URL-1', 'Today 12:30'),
      ('PDF-2', 'Today 13:30'),
      ('URL-2', 'Today 18:30'),
    ];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('History:')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.qr_code_2),
            const SizedBox(width: 12),
            Expanded(child: Text(items[i].$1, style: Theme.of(context).textTheme.titleMedium)),
            Text(items[i].$2, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}
