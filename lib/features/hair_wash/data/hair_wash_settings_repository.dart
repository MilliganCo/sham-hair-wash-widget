import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/date_utils.dart';
import '../domain/hair_wash_models.dart';

class HairWashSettingsRepository {
  static const String _titleKey = 'widgetTitle';
  static const String _intervalKey = 'washIntervalDays';
  static const String _lastWashKey = 'lastWashDate';

  Future<HairWashSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final settings = HairWashSettings(
      widgetTitle:
          preferences.getString(_titleKey) ??
          HairWashSettings.defaults().widgetTitle,
      washIntervalDays:
          preferences.getInt(_intervalKey) ??
          HairWashSettings.defaults().washIntervalDays,
      lastWashDate: parseDateIso(preferences.getString(_lastWashKey)),
    );
    return settings;
  }

  Future<void> save(HairWashSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_titleKey, settings.widgetTitle);
    await preferences.setInt(_intervalKey, settings.washIntervalDays);
    if (settings.lastWashDate == null) {
      await preferences.remove(_lastWashKey);
    } else {
      await preferences.setString(
        _lastWashKey,
        formatDateIso(settings.lastWashDate!),
      );
    }
  }
}
