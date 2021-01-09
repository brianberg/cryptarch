import "dart:io";

import "package:flutter/material.dart";

import "package:file_picker/file_picker.dart";

import "package:cryptarch/models/models.dart" show Miner, Energy;
import "package:cryptarch/services/services.dart" show CsvService;
import "package:cryptarch/widgets/widgets.dart";

class MinerEnergyUsagePage extends StatelessWidget {
  final Miner miner;

  MinerEnergyUsagePage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = {
      "minerId": this.miner.id,
    };
    return Scaffold(
      appBar: FlatAppBar(
        title: Text("${this.miner.name} Energy Usage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () async {
              try {
                final file = await this._export();
                if (file != null) {
                  print("successfully exported energy usage");
                  // TODO: show success alert
                }
              } catch (err) {
                print("unable to export energy usage: $err");
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: EnergyList(
          filters: filters,
        ),
      ),
    );
  }

  Future<File> _export() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      List<Energy> energyUsages = await Energy.find(filters: {
        "minerId": this.miner.id,
      });
      List<List<dynamic>> rows = energyUsages
          .map(
            (energy) => energy.toCsv(),
          )
          .toList();
      String minerName = this.miner.name.replaceAll(" ", "-").toLowerCase();
      String filepath = "$path/${minerName}_energy-usage.csv";
      return CsvService.export(
        filepath,
        rows,
        appendTimestamp: true,
      );
    }

    return null;
  }
}
