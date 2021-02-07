import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class AssetList extends StatelessWidget {
  final Function onTap;
  final List<Asset> items;
  final Map<String, dynamic> options;

  AssetList({
    Key key,
    this.items,
    this.onTap,
    this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No assets")),
      );
    }

    return Column(
      children: this.items.map((asset) {
        return AssetListItem(
          asset: asset,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
