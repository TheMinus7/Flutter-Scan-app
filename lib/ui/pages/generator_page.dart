import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'home_page.dart' show QrType;
import '../../services/local_share_server.dart';
import '../../services/history_store.dart';

class GeneratorPage extends StatefulWidget {
  final QrType initialType;
  const GeneratorPage({super.key, required this.initialType});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  late QrType selected;
  final linkCtrl = TextEditingController();
  final wifiSsid = TextEditingController();
  final wifiPass = TextEditingController();
  final textCtrl = TextEditingController();
  final emailAddr = TextEditingController();
  final emailSubj = TextEditingController();
  final phoneCtrl = TextEditingController();
  String data = '';

  @override
  void initState() {
    super.initState();
    selected = widget.initialType;
  }

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

  Future<void> generate() async {
    final payload = buildData();
    setState(() => data = payload);
    final label = labelOf(selected);
    await HistoryStore.add(HistoryItem(
      type: label.toLowerCase(),
      payload: payload,
      title: label,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _pickAndHostFile() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    final file = File(path);
    final url = await LocalShareServer().addFile(file);
    setState(() {
      selected = QrType.image;
      linkCtrl.text = url;
      data = url;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File hosted → link ready')));
  }

  Future<void> _copyLink() async {
    if (data.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('QR code preview')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: data.isEmpty
                    ? const SizedBox(height: 220, width: 220)
                    : QrImageView(
                        data: data,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.square),
                        dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.square),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(onPressed: () {}, child: Text(labelOf(selected))),
            ),
            const SizedBox(height: 12),
            _form(cs),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: generate, child: const Text('Create'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.tonal(onPressed: _copyLink, child: const Text('Copy link'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAndHostFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload PDF/Image'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(ColorScheme cs) {
    InputDecoration deco(String h) => InputDecoration(
          hintText: h,
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        );

    switch (selected) {
      case QrType.link:
      case QrType.image:
        return TextField(controller: linkCtrl, keyboardType: TextInputType.url, decoration: deco('https://…'));
      case QrType.text:
        return TextField(controller: textCtrl, maxLines: 3, decoration: deco('Текст…'));
      case QrType.email:
        return Column(children: [
          TextField(controller: emailAddr, keyboardType: TextInputType.emailAddress, decoration: deco('email@example.com')),
          const SizedBox(height: 10),
          TextField(controller: emailSubj, decoration: deco('Subject')),
        ]);
      case QrType.wifi:
        return Column(children: [
          TextField(controller: wifiSsid, decoration: deco('SSID')),
          const SizedBox(height: 10),
          TextField(controller: wifiPass, obscureText: true, decoration: deco('Password')),
        ]);
      case QrType.phone:
        return TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: deco('+976…'));
    }
  }

  String labelOf(QrType t) {
    switch (t) {
      case QrType.link:
        return 'URL';
      case QrType.wifi:
        return 'Wi-Fi';
      case QrType.text:
        return 'Text';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
      case QrType.image:
        return 'File';
    }
  }
}
