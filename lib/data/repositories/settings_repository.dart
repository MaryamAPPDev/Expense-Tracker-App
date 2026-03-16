import 'package:hive/hive.dart';
import '../hive/hive_service.dart';

class SettingsRepository {
  final Box _box = Hive.box(HiveService.settingsBox);

  bool get isDarkMode => _box.get('isDarkMode', defaultValue: false);
  Future<void> setDarkMode(bool value) async => await _box.put('isDarkMode', value);
}
