import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";

import "asset_picker_list.widget.dart";

class AssetPicker extends StatelessWidget {
  final String title;
  final List<Asset> assets;
  final Asset selected;

  AssetPicker({
    Key key,
    this.title = "Assets",
    this.assets,
    this.selected,
  })  : assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, this.selected);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              final symbol = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAssetPage(),
                ),
              );
              final asset = await Asset.findOneBySymbol(symbol);
              Navigator.pop(context, asset);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AssetPickerList(
          items: this.assets,
          selectedItem: this.selected,
          onTap: (Asset selected) {
            Navigator.pop(context, selected);
          },
        ),
      ),
    );
  }
}
