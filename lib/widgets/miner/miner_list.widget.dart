import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class MinerList extends StatelessWidget {
  final Function onTap;
  final List<Miner> items;

  MinerList({
    Key key,
    this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No miners")),
      );
    }

    return Column(
      children: this.items.map((miner) {
        return MinerListItem(
          miner: miner,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
