import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum QrType { link, wifi, text, email, phone }

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
  String qrData = '';

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

  String _buildData() {
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
    }
  }

  void _generate() {
    setState(() => qrData = _buildData());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;
          final left = _LeftPane(
            selected: selected,
            onPick: (t) => setState(() => selected = t),
            form: _FormArea(
              type: selected,
              linkCtrl: linkCtrl,
              wifiSsid: wifiSsid,
              wifiPass: wifiPass,
              textCtrl: textCtrl,
              emailAddr: emailAddr,
              emailSubj: emailSubj,
              phoneCtrl: phoneCtrl,
              onGenerate: _generate,
            ),
          );
          final right = _RightPane(
            data: qrData,
            onGenerate: _generate,
            onSave: () {},
          );
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isWide
                    ? Row(children: [
                        Expanded(child: left),
                        const SizedBox(width: 24),
                        Expanded(child: right),
                      ])
                    : ListView(children: [
                        left,
                        const SizedBox(height: 24),
                        right,
                      ]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: null,
    );
  }
}

class _LeftPane extends StatelessWidget {
  final QrType selected;
  final ValueChanged<QrType> onPick;
  final Widget form;
  const _LeftPane(
      {required this.selected, required this.onPick, required this.form});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QR Generator',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            physics: const NeverScrollableScrollPhysics(),
            children: QrType.values.map((t) {
              final active = t == selected;
              return InkWell(
                onTap: () => onPick(t),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: active ? cs.primary : cs.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      _label(t),
                      style: TextStyle(
                          color: active ? cs.onPrimary : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          form,
        ]),
      ),
    );
  }

  String _label(QrType t) {
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
    }
  }
}

class _FormArea extends StatelessWidget {
  final QrType type;
  final TextEditingController linkCtrl;
  final TextEditingController wifiSsid;
  final TextEditingController wifiPass;
  final TextEditingController textCtrl;
  final TextEditingController emailAddr;
  final TextEditingController emailSubj;
  final TextEditingController phoneCtrl;
  final VoidCallback onGenerate;

  const _FormArea({
    required this.type,
    required this.linkCtrl,
    required this.wifiSsid,
    required this.wifiPass,
    required this.textCtrl,
    required this.emailAddr,
    required this.emailSubj,
    required this.phoneCtrl,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    InputDecoration deco(String h) => InputDecoration(
          hintText: h,
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        );

    List<Widget> children;
    switch (type) {
      case QrType.link:
        children = [
          TextField(
              controller: linkCtrl,
              keyboardType: TextInputType.url,
              decoration: deco('https://…')),
        ];
        break;
      case QrType.wifi:
        children = [
          TextField(controller: wifiSsid, decoration: deco('SSID')),
          const SizedBox(height: 10),
          TextField(
              controller: wifiPass,
              obscureText: true,
              decoration: deco('Password')),
        ];
        break;
      case QrType.text:
        children = [
          TextField(
              controller: textCtrl, maxLines: 3, decoration: deco('Текст')),
        ];
        break;
      case QrType.email:
        children = [
          TextField(
              controller: emailAddr,
              keyboardType: TextInputType.emailAddress,
              decoration: deco('Email')),
          const SizedBox(height: 10),
          TextField(controller: emailSubj, decoration: deco('Subject')),
        ];
        break;
      case QrType.phone:
        children = [
          TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: deco('+976…')),
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...children,
        const SizedBox(height: 12),
        FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Үүсгэх')),
      ],
    );
  }
}

class _RightPane extends StatelessWidget {
  final String data;
  final VoidCallback onGenerate;
  final VoidCallback onSave;
  const _RightPane(
      {required this.data, required this.onGenerate, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
            child: Center(
              child: data.isEmpty
                  ? Text('QR харагдац',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: cs.onSurfaceVariant))
                  : QrImageView(
                      data: data, version: QrVersions.auto, size: 260),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save')),
              const SizedBox(width: 8),
              FilledButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Дахин')),
            ],
          )
        ]),
      ),
    );
  }
}
