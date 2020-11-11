import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/ui/widgets.dart";

class AssetList extends StatelessWidget {
  final Function onTap;
  final List<Asset> items;
  final Asset selectedItem;
  final Map<String, dynamic> options;

  AssetList({
    Key key,
    this.items,
    this.selectedItem,
    this.onTap,
    this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items != null) {
      return _buildList(items);
    }

    return FutureBuilder<List<Asset>>(
      future: Asset.find(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Asset>> snapshot,
      ) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) return Text("Error: ${snapshot.error}");
            List<Asset> assets = snapshot.data;
            return _buildList(assets);
        }
        return Container(child: const Text("Unable to get assets"));
      },
    );
  }

  Widget _buildList(List<Asset> assets) {
    if (assets.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (BuildContext context, int index) {
        final asset = assets[index];
        var selected = false;
        if (this.selectedItem != null) {
          selected = this.selectedItem.id == asset.id;
        }
        return AssetListItem(
          asset: asset,
          selected: selected,
          onTap: this.onTap,
        );
      },
    );
  }
}
