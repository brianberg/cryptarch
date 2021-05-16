import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/widgets/widgets.dart";

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

    final amount = this.item.amount.toStringAsFixed(3);
    final value = NumberFormat.simpleCurrency().format(this.item.value);
    final valueChange = this.item.valueChange;

    final asset = this.item.asset;
    final assetValue = NumberFormat.simpleCurrency().format(asset.value);

    return InkWell(
      key: ValueKey(this.item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 16.0),
        child: Row(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 32.0,
                    width: 32.0,
                    child: AssetIcon(asset: asset),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: theme.textTheme.bodyText2,
                    ),
                    Text(
                      "$amount ${asset.symbol}",
                      style: theme.textTheme.caption.copyWith(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 96.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          assetValue,
                          style: theme.textTheme.bodyText2.copyWith(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        PercentChange(
                          value: asset.percentChange,
                          style: theme.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.bodyText2.copyWith(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        CurrencyChange(
                          value: valueChange,
                          style: theme.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (this.onTap != null) {
          this.onTap(this.item);
        }
      },
    );
  }
}
