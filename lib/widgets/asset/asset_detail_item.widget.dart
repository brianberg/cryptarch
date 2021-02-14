import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset;

import "package:cryptarch/widgets/widgets.dart";

class AssetDetailItem extends StatelessWidget {
  final Asset asset;
  final Function onTap;

  AssetDetailItem({
    Key key,
    @required this.asset,
    this.onTap,
  })  : assert(asset != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fiatFormat = NumberFormat.simpleCurrency();

    final assetValue = fiatFormat.format(this.asset.value);

    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                this.asset.name,
                style: theme.textTheme.subtitle2,
              ),
              Text(assetValue, style: theme.textTheme.headline6),
              PercentChange(
                value: this.asset.percentChange,
                style: theme.textTheme.subtitle2,
              ),
            ],
          ),
          AssetIcon(asset: this.asset),
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
