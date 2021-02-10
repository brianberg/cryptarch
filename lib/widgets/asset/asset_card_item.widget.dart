import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset;

import "package:cryptarch/widgets/widgets.dart";

class AssetCardItem extends StatelessWidget {
  final Asset asset;
  final Function onTap;

  AssetCardItem({
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

    return Card(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 32.0,
                    width: 32.0,
                    child: AssetIcon(asset: asset),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          this.asset.symbol,
                          style: theme.textTheme.subtitle2.copyWith(
                            color: theme.textTheme.bodyText1.color,
                          ),
                        ),
                        Text(
                          assetValue,
                          style: theme.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: PercentChange(
                  value: this.asset.percentChange,
                  style: theme.textTheme.headline6,
                ),
              ),
            ],
          ),
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
