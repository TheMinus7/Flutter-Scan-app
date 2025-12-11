import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String type;      // link/wifi/text/email/phone/image
  final String payload;   // exact QR data string
  final String title;     // short label
  final DateTime createdAt;

  HistoryItem({
    required this.type,
    required this.payload,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'payload': payload,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };

  static HistoryItem fromJson(Map<String, dynamic> j) => HistoryItem(
    type: j['type'],
    payload: j['payload'],
    title: j['title'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}

class HistoryStore {
  static const _key = 'qr_history_v1';

  static Future<List<HistoryItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? [];
    final list = raw.map((s) => HistoryItem.fromJson(jsonDecode(s))).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> add(HistoryItem item) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    list.add(jsonEncode(item.toJson()));
    await sp.setStringList(_key, list);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
