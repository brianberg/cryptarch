import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/ui/widgets.dart";

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final Function onTap;

  AssetListItem({
    Key key,
    @required this.asset,
    this.onTap,
  })  : assert(asset != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final value = NumberFormat.simpleCurrency().format(this.asset.value);
    final changePrefix = this.asset.percentChange > 0 ? '+' : '';
    final percentChange = "${this.asset.percentChange.toStringAsFixed(2)}%";

    return Padding(
      key: ValueKey(this.asset.id),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 32.0,
              width: 32.0,
              child: AssetIcon(asset: this.asset),
            ),
          ],
        ),
        title: Text(
          this.asset.name,
          style: TextStyle(
            color: theme.textTheme.bodyText1.color,
          ),
        ),
        subtitle: Text(
          this.asset.symbol,
          style: theme.textTheme.subtitle2,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyText1,
            ),
            Text(
              "$changePrefix$percentChange",
              style: theme.textTheme.subtitle2,
            ),
          ],
        ),
        onTap: this.onTap != null
            ? () {
                this.onTap(this.asset);
              }
            : null,
      ),
    );
  }
}
