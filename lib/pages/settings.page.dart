import "package:flutter/material.dart";

import "package:provider/provider.dart";
import "package:settings_ui/settings_ui.dart";

import "package:cryptarch/services/services.dart" show SettingsService;
import "package:cryptarch/ui/widgets.dart";

class SettingsPage extends StatelessWidget {
  static final routeName = "/settings";

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final settings = settingsService.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            SettingsSection(
              title: "Features",
              tiles: [
                SettingsTile.switchTile(
                  title: "Mining",
                  switchValue: settings.showMining,
                  onToggle: (bool value) async {
                    settings.showMining = value;
                    await settingsService.saveSettings(settings);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
