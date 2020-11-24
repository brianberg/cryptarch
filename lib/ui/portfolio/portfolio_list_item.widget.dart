import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/ui/widgets.dart";

class PortfolioListItem extends StatelessWidget {
  final PortfolioItem item;
  final Function onTap;

  PortfolioListItem({
    Key key,
    @required this.item,
    this.onTap,
  })  : assert(item != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = this.item.amount.toStringAsFixed(6);
    final value = NumberFormat.simpleCurrency().format(this.item.value);

    return ListTile(
      key: ValueKey(this.item),
      title: Text(
        this.item.asset.name,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 32.0,
            width: 32.0,
            child: AssetIcon(asset: this.item.asset),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value),
          Text(
            "$amount ${this.item.asset.symbol}",
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
      onTap: () {
        if (this.onTap != null) {
          this.onTap(this.item);
        }
      },
    );
  }
}
