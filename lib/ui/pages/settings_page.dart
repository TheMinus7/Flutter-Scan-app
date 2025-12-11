import 'package:flutter/material.dart';
import '../../services/settings_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int appearance = 0;
  int eye = 1;
  int dot = 1;
  double quiet = 16;
  bool transparentBg = false;
  bool autoSave = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = SettingsStore();
    await s.load();
    setState(() {
      appearance = s.appearance;
      eye = s.eye;
      dot = s.dot;
      quiet = s.quiet;
      transparentBg = s.transparent;
      autoSave = s.autosave;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final s = SettingsStore()
      ..appearance = appearance
      ..eye = eye
      ..dot = dot
      ..quiet = quiet
      ..transparent = transparentBg
      ..autosave = autoSave;
    await s.save();
  }

  Future<void> _setAppearance(int v) async {
    setState(() => appearance = v);
    await _save();
  }

  Future<void> _setEye(int v) async {
    setState(() => eye = v);
    await _save();
  }

  Future<void> _setDot(int v) async {
    setState(() => dot = v);
    await _save();
  }

  Future<void> _setQuiet(double v) async {
    setState(() => quiet = v);
    await _save();
  }

  Future<void> _setTransparent(bool v) async {
    setState(() => transparentBg = v);
    await _save();
  }

  Future<void> _setAutosave(bool v) async {
    setState(() => autoSave = v);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final section = (String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            child,
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Тохиргоо')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          section('Theme', Row(children: [
            _seg('System', 0, group: appearance, onTap: () => _setAppearance(0)),
            const SizedBox(width: 8),
            _seg('Light', 1, group: appearance, onTap: () => _setAppearance(1)),
            const SizedBox(width: 8),
            _seg('Dark', 2, group: appearance, onTap: () => _setAppearance(2)),
          ])),
          section('QR Style', Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Eye style'),
              const SizedBox(height: 6),
              Row(children: [
                _seg('Square', 0, group: eye, onTap: () => _setEye(0)),
                const SizedBox(width: 8),
                _seg('Rounded', 1, group: eye, onTap: () => _setEye(1)),
              ]),
              const SizedBox(height: 10),
              const Text('Dot style'),
              const SizedBox(height: 6),
              Row(children: [
                _seg('Square', 0, group: dot, onTap: () => _setDot(0)),
                const SizedBox(width: 8),
                _seg('Rounded', 1, group: dot, onTap: () => _setDot(1)),
                const SizedBox(width: 8),
                _seg('Circle', 2, group: dot, onTap: () => _setDot(2)),
              ]),
              const SizedBox(height: 10),
              Row(children: [const Expanded(child: Text('Quiet zone')), Text('${quiet.toInt()} px')]),
              Slider(value: quiet, min: 0, max: 32, onChanged: (v) => _setQuiet(v)),
            ],
          )),
          section('Export', Column(
            children: [
              _switchRow('Transparent background', transparentBg, _setTransparent),
              _switchRow('Auto-save to Gallery', autoSave, _setAutosave),
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

  Widget _switchRow(String title, bool value, Future<void> Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Switch(
          value: value,
          onChanged: (v) => onChanged(v),
        ),
      ],
    );
  }
}
