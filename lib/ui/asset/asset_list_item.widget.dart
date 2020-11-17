import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Asset;

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

    final percentChange = this.asset.percentChange;

    return Padding(
      key: ValueKey(this.asset.id),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Card(
        elevation: 1.0,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: theme.colorScheme.onSurface,
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
            this.asset.currency,
            style: theme.textTheme.subtitle1,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${this.asset.value.toStringAsFixed(2)}",
                style: theme.textTheme.bodyText1,
              ),
              Text(
                "${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(2)}%",
                style: theme.textTheme.subtitle1,
              ),
            ],
          ),
          onTap: this.onTap != null
              ? () {
                  this.onTap(this.asset);
                }
              : null,
        ),
      ),
    );
  }
}
