import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/widgets/widgets.dart";

class MinerPayoutsPage extends StatelessWidget {
  final Miner miner;

  MinerPayoutsPage({
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
        title: Text("${this.miner.name} Payouts"),
      ),
      body: SafeArea(
        child: PayoutList(
          filters: filters,
        ),
      ),
    );
  }
}
