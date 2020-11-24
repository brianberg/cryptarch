import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner;

class MinerListItem extends StatelessWidget {
  final Miner miner;
  final Function onTap;

  MinerListItem({
    Key key,
    @required this.miner,
    this.onTap,
  })  : assert(miner != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = this.miner.asset.symbol;
    final profitability = this.miner.profitability.toStringAsFixed(6);
    final fiatProfitability =
        NumberFormat.simpleCurrency().format(this.miner.fiatProfitability);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          this.miner.name,
          style: TextStyle(
            color: theme.textTheme.bodyText1.color,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("$profitability $symbol"),
            Text(
              "$fiatProfitability / day",
              style: theme.textTheme.subtitle2,
            ),
          ],
        ),
        onTap: () {
          if (this.onTap != null) {
            this.onTap(this.miner);
          }
        },
      ),
    );
  }
}
