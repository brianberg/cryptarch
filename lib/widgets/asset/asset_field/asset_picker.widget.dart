import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/widgets/widgets.dart";

import "asset_picker_list_item.widget.dart";

class AssetPicker extends StatelessWidget {
  static Route route({String title, List<Asset> assets, Asset selected}) {
    return MaterialPageRoute<void>(
      builder: (_) => AssetPicker(
        title: title,
        assets: assets,
        selected: selected,
      ),
    );
  }

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
                AssetAddPage.route(),
              );
              final asset = await Asset.findOneBySymbol(symbol);
              Navigator.pop(context, asset);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: this.assets != null
              ? this._buildList(this.assets)
              : FutureBuilder<List<Asset>>(
                  future: Asset.find(orderBy: "name"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return _buildList(snapshot.data);
                    }

                    return LoadingIndicator();
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildList(List<Asset> assets) {
    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (BuildContext context, int index) {
        final asset = assets[index];
        var selected = false;
        if (this.selected != null) {
          selected = this.selected.id == asset.id;
        }
        return AssetPickerListItem(
          asset: asset,
          selected: selected,
          onTap: (Asset selected) {
            Navigator.pop(context, selected);
          },
        );
      },
    );
  }
}
