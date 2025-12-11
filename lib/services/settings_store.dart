import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const _ap = 'appearance'; // 0 system, 1 light, 2 dark
  static const _eye = 'eye';        // 0 square, 1 rounded
  static const _dot = 'dot';        // 0 square, 1 rounded, 2 circle
  static const _quiet = 'quiet';    // double
  static const _transparent = 'transparent';
  static const _autosave = 'autosave';

  int appearance = 0;
  int eye = 1;
  int dot = 1;
  double quiet = 16;
  bool transparent = false;
  bool autosave = false;

  static final SettingsStore _i = SettingsStore._();
  SettingsStore._();
  factory SettingsStore() => _i;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    appearance = sp.getInt(_ap) ?? 0;
    eye = sp.getInt(_eye) ?? 1;
    dot = sp.getInt(_dot) ?? 1;
    quiet = sp.getDouble(_quiet) ?? 16;
    transparent = sp.getBool(_transparent) ?? false;
    autosave = sp.getBool(_autosave) ?? false;
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_ap, appearance);
    await sp.setInt(_eye, eye);
    await sp.setInt(_dot, dot);
    await sp.setDouble(_quiet, quiet);
    await sp.setBool(_transparent, transparent);
    await sp.setBool(_autosave, autosave);
  }
}
