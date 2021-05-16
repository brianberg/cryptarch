import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show InventoryItem;
import "package:cryptarch/widgets/widgets.dart";

class InventoryList extends StatelessWidget {
  final Function onTap;
  final List<InventoryItem> items;

  InventoryList({
    Key key,
    this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No items")),
      );
    }

    return Column(
      children: this.items.map((item) {
        return InventoryListItem(
          item: item,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
