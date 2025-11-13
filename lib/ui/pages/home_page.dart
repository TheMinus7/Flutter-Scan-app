import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum QrType { link, wifi, text, email, phone, image }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QrType selected = QrType.link;
  final linkCtrl = TextEditingController();
  final wifiSsid = TextEditingController();
  final wifiPass = TextEditingController();
  final textCtrl = TextEditingController();
  final emailAddr = TextEditingController();
  final emailSubj = TextEditingController();
  final phoneCtrl = TextEditingController();
  String data = '';

  @override
  void dispose() {
    linkCtrl.dispose();
    wifiSsid.dispose();
    wifiPass.dispose();
    textCtrl.dispose();
    emailAddr.dispose();
    emailSubj.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  String buildData() {
    switch (selected) {
      case QrType.link:
        return linkCtrl.text.trim();
      case QrType.wifi:
        final ssid = wifiSsid.text.trim();
        final p = wifiPass.text;
        return 'WIFI:T:WPA;S:$ssid;P:$p;;';
      case QrType.text:
        return textCtrl.text;
      case QrType.email:
        final to = Uri.encodeComponent(emailAddr.text.trim());
        final sub = Uri.encodeComponent(emailSubj.text);
        return 'mailto:$to?subject=$sub';
      case QrType.phone:
        return 'tel:${phoneCtrl.text.trim()}';
      case QrType.image:
        return linkCtrl.text.trim();
    }
  }

  void generate() {
    setState(() => data = buildData());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 720;
    final cs = Theme.of(context).colorScheme;

    final left = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QR Generator', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: QrType.values.map((t) {
                final active = t == selected;
                return InkWell(
                  onTap: () => setState(() => selected = t),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? cs.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: active ? cs.primary : cs.outlineVariant),
                    ),
                    child: Text(
                      labelOf(t),
                      style: TextStyle(color: active ? cs.onPrimary : cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            formArea(cs),
          ]),
        ),
      ),
    );

    final right = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
            child: Center(
              child: data.isEmpty
                  ? Text('QR харагдац', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant))
                  : QrImageView(data: data, version: QrVersions.auto, size: 260),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.save_outlined), label: const Text('Save')),
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Дахин')),
            ],
          ),
        ]),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isWide
                ? Row(children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)])
                : Column(children: [left, const SizedBox(height: 16), SizedBox(height: 380, child: right)]),
          ),
        ),
      ),
    );
  }

  Widget formArea(ColorScheme cs) {
    InputDecoration deco(String h) => InputDecoration(
          hintText: h,
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        );

    switch (selected) {
      case QrType.link:
        return Column(children: [
          TextField(controller: linkCtrl, keyboardType: TextInputType.url, decoration: deco('https://…')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
      case QrType.wifi:
        return Column(children: [
          TextField(controller: wifiSsid, decoration: deco('SSID')),
          const SizedBox(height: 10),
          TextField(controller: wifiPass, obscureText: true, decoration: deco('Password')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
      case QrType.text:
        return Column(children: [
          TextField(controller: textCtrl, maxLines: 3, decoration: deco('Текст')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
      case QrType.email:
        return Column(children: [
          TextField(controller: emailAddr, keyboardType: TextInputType.emailAddress, decoration: deco('Email')),
          const SizedBox(height: 10),
          TextField(controller: emailSubj, decoration: deco('Subject')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
      case QrType.phone:
        return Column(children: [
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: deco('+976…')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
      case QrType.image:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: linkCtrl, keyboardType: TextInputType.url, decoration: deco('https://… (image URL)')),
          const SizedBox(height: 8),
          Text('Зургийн линк оруулаад Үүсгэх дарна.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: generate, icon: const Icon(Icons.qr_code_2), label: const Text('Үүсгэх')),
        ]);
    }
  }

  String labelOf(QrType t) {
    switch (t) {
      case QrType.link:
        return 'Link';
      case QrType.wifi:
        return 'Wi-Fi';
      case QrType.text:
        return 'Text';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
      case QrType.image:
        return 'Image';
    }
  }
}
