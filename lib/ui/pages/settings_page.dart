import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int appearance = 0; // 0 system, 1 light, 2 dark
  int eye = 1;        // 0 square, 1 rounded
  int dot = 1;        // 0 square, 1 rounded, 2 circle
  double quiet = 16;
  bool transparentBg = false;
  bool autoSave = false;

  @override
  Widget build(BuildContext context) {
    final section = (String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          child,
        ]),
      ),
    );

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Тохиргоо')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          section('Theme', Row(children: [
            _seg('System', 0, group: appearance, onTap: () => setState(() => appearance = 0)),
            const SizedBox(width: 8),
            _seg('Light', 1, group: appearance, onTap: () => setState(() => appearance = 1)),
            const SizedBox(width: 8),
            _seg('Dark', 2, group: appearance, onTap: () => setState(() => appearance = 2)),
          ])),
          section('QR Style', Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Eye style'),
              const SizedBox(height: 6),
              Row(children: [
                _seg('Square', 0, group: eye, onTap: () => setState(() => eye = 0)),
                const SizedBox(width: 8),
                _seg('Rounded', 1, group: eye, onTap: () => setState(() => eye = 1)),
              ]),
              const SizedBox(height: 10),
              const Text('Dot style'),
              const SizedBox(height: 6),
              Row(children: [
                _seg('Square', 0, group: dot, onTap: () => setState(() => dot = 0)),
                const SizedBox(width: 8),
                _seg('Rounded', 1, group: dot, onTap: () => setState(() => dot = 1)),
                const SizedBox(width: 8),
                _seg('Circle', 2, group: dot, onTap: () => setState(() => dot = 2)),
              ]),
              const SizedBox(height: 10),
              Row(children: [const Expanded(child: Text('Quiet zone')), Text('${quiet.toInt()} px')]),
              Slider(value: quiet, min: 0, max: 32, onChanged: (v) => setState(() => quiet = v)),
            ],
          )),
          section('Export', Column(
            children: [
              _switchRow('Transparent background', transparentBg, (v) => setState(() => transparentBg = v)),
              _switchRow('Auto-save to Gallery', autoSave, (v) => setState(() => autoSave = v)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _seg(String label, int value, {required int group, required VoidCallback onTap}) {
    final selected = value == group;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(label, style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface)),
      ),
    );
  }

  Widget _switchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(children: [Expanded(child: Text(title)), Switch(value: value, onChanged: onChanged)]);
  }
}
