import "package:cryptarch/services/services.dart" show StorageService;
import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Settings;

const SETTINGS_KEY = "settings";

class SettingsService extends ChangeNotifier {
  Settings _settings;

  Settings get settings {
    return this._settings;
  }

  Future<Settings> getSettings() async {
    final rawSettings = await StorageService.getItem(SETTINGS_KEY);
    final settings =
        rawSettings != null ? Settings.fromMap(rawSettings) : Settings();

    this._settings = settings;

    return settings;
  }

  Future<void> saveSettings(Settings settings) async {
    final rawSettings = settings.toJson();
    await StorageService.putItem(SETTINGS_KEY, rawSettings);
    this._settings = settings;
    notifyListeners();
  }
}
