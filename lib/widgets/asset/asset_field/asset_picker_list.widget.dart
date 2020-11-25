import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

import "asset_picker_list_item.widget.dart";

class AssetPickerList extends StatelessWidget {
  final Function onTap;
  final List<Asset> items;
  final Asset selectedItem;
  final Map<String, dynamic> options;

  AssetPickerList({
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (BuildContext context, int index) {
          final asset = assets[index];
          var selected = false;
          if (this.selectedItem != null) {
            selected = this.selectedItem.id == asset.id;
          }
          return AssetPickerListItem(
            asset: asset,
            selected: selected,
            onTap: this.onTap,
          );
        },
      ),
    );
  }
}
