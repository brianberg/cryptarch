import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show InventoryItem;

class InventoryListItem extends StatelessWidget {
  final InventoryItem item;
  final Function onTap;

  InventoryListItem({
    Key key,
    @required this.item,
    this.onTap,
  })  : assert(item != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cost = NumberFormat.simpleCurrency()
        .format(this.item.cost * this.item.quantity);

    return ListTile(
      key: ValueKey(this.item.id),
      title: Text(
        this.item.name,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            cost,
            style: theme.textTheme.bodyText1.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            "Quantity: ${this.item.quantity}",
            style: theme.textTheme.subtitle2.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
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
