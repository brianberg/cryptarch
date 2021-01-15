import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/widgets/widgets.dart";

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

    return ListTile(
      key: ValueKey(this.asset.id),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyText1.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          PercentChange(
            value: this.asset.percentChange,
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
      onTap: this.onTap != null
          ? () {
              this.onTap(this.asset);
            }
          : null,
    );
  }
}
