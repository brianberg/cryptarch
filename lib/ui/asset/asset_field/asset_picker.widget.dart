import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";

import "asset_picker_list.widget.dart";

class AssetPicker extends StatefulWidget {
  final String title;
  final List<Asset> assets;
  final Asset selected;

  AssetPicker({
    Key key,
    @required this.title,
    this.assets,
    this.selected,
  })  : assert(title != null),
        super(key: key);

  @override
  _AssetPickerState createState() => _AssetPickerState();
}

class _AssetPickerState extends State<AssetPicker> {
  Asset asset;

  @override
  void initState() {
    super.initState();
    setState(() {
      asset = widget.selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, this.asset);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final symbol = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAssetPage(),
                ),
              );
              final asset = await Asset.findOneBySymbol(symbol);
              setState(() {
                this.asset = asset;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AssetPickerList(
          items: widget.assets,
          selectedItem: this.asset,
          onTap: (Asset selected) {
            final isSelected =
                this.asset != null && this.asset.id == selected.id;
            setState(() {
              asset = isSelected ? null : selected;
            });
          },
        ),
      ),
    );
  }
}
