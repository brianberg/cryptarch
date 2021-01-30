import "dart:io";

import "package:flutter/material.dart";

import "package:file_picker/file_picker.dart";
import "package:provider/provider.dart";
import "package:settings_ui/settings_ui.dart";

import "package:cryptarch/models/models.dart" show Account, Transaction;
import "package:cryptarch/services/services.dart"
    show CsvService, SettingsService;
import "package:cryptarch/widgets/widgets.dart";

class SettingsPage extends StatelessWidget {
  static final routeName = "/settings";

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final settings = settingsService.settings;

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: SettingsList(
          sections: [
            // SettingsSection(
            //   title: "Features",
            //   tiles: [
            //     SettingsTile.switchTile(
            //       title: "Mining",
            //       leading: Icon(Icons.engineering),
            //       switchValue: settings.showMining,
            //       onToggle: (bool value) async {
            //         settings.showMining = value;
            //         await settingsService.saveSettings(settings);
            //       },
            //     ),
            //   ],
            // ),
            SettingsSection(
              title: "Export",
              tiles: [
                SettingsTile(
                  title: "Accounts",
                  leading: Icon(Icons.pie_chart),
                  onTap: () async {
                    try {
                      final file = await this._exportAccounts();
                      if (file != null) {
                        print("successfully exported accounts");
                        // TODO: show success alert
                      }
                    } catch (err) {
                      print("unable to export accounts: $err");
                    }
                  },
                ),
                SettingsTile(
                  title: "Transactions",
                  leading: Icon(Icons.swap_horiz),
                  onTap: () async {
                    try {
                      final file = await this._exportTransactions();
                      if (file != null) {
                        print("successfully exported transactions");
                        // TODO: show success alert
                      }
                    } catch (err) {
                      print("unable to export transactions: $err");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _exportAccounts() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      List<Account> accounts = await Account.find();
      List<List<dynamic>> rows = accounts
          .map(
            (account) => account.toCsv(),
          )
          .toList();
      String filepath = "$path/cryptarch-accounts.csv";
      return CsvService.export(
        filepath,
        rows,
        headers: Account.csvHeaders,
        appendTimestamp: true,
      );
    }

    return null;
  }

  Future<File> _exportTransactions() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      List<Transaction> transactions = await Transaction.find();
      List<List<dynamic>> rows = transactions
          .map(
            (transaction) => transaction.toCsv(),
          )
          .toList();
      String filepath = "$path/cryptarch-transactions.csv";
      return CsvService.export(
        filepath,
        rows,
        headers: Transaction.csvHeaders,
        appendTimestamp: true,
      );
    }

    return null;
  }
}
