import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/widgets/widgets.dart";

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

    final asset = this.miner.asset;
    final profitability = this.miner.profitability.toStringAsFixed(6);
    final fiatProfitability =
        NumberFormat.simpleCurrency().format(this.miner.fiatProfitability);

    return ListTile(
      key: ValueKey(this.miner.id),
      title: Text(
        this.miner.name,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      subtitle: Text(
        this.miner.active ? "Active" : "Inactive",
        style: theme.textTheme.subtitle2,
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 32.0,
            width: 32.0,
            child: AssetIcon(asset: asset),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$profitability ${asset.symbol}",
            style: theme.textTheme.bodyText1.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            "$fiatProfitability / day",
            style: theme.textTheme.subtitle2.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      onTap: () {
        if (this.onTap != null) {
          this.onTap(this.miner);
        }
      },
    );
  }
}
