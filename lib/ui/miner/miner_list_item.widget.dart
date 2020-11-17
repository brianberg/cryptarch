import "package:flutter/material.dart";

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

    final currency = this.miner.holding.currency;
    final fiatProfitability = this.miner.calculateFiatProfitability();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Card(
        elevation: 1.0,
        child: ListTile(
          title: Text(miner.name),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${miner.profitability.toStringAsFixed(6)} $currency",
              ),
              Text(
                "\$${fiatProfitability.toStringAsFixed(2)} / day",
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
      ),
    );
  }
}
