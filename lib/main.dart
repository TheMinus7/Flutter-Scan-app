import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/pages/shell_page.dart';

void main() {
  runApp(const ScanApp());
}

class ScanApp extends StatelessWidget {
  const ScanApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const ShellPage(),
    );
  }
}
