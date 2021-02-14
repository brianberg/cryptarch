import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

import "asset_picker_list_item.widget.dart";

class AssetPicker extends StatefulWidget {
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
  _AssetPickerState createState() => _AssetPickerState();
}

class _AssetPickerState extends State<AssetPicker> {
  List<Asset> assets;
  Asset selected;

  @override
  void initState() {
    super.initState();
    if (this.widget.assets != null) {
      setState(() {
        this.selected = this.widget.selected;
        this.assets = this.widget.assets;
      });
    } else {
      Asset.find(orderBy: "name").then((assets) {
        setState(() {
          this.assets = assets;
          this.selected = this.widget.selected;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlatAppBar(
        title: Text(widget.title),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, this.selected);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              final currency = await Navigator.push(
                context,
                AssetAddPage.route(),
              );
              if (currency != null) {
                final asset = await this._createAsset(currency);
                setState(() {
                  this.assets.insert(0, asset);
                  this.selected = asset;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: this.assets != null
              ? ListView.builder(
                  itemCount: this.assets.length,
                  itemBuilder: (BuildContext context, int index) {
                    final asset = this.assets[index];
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
                )
              : LoadingIndicator(),
        ),
      ),
    );
  }

  Future<Asset> _createAsset(Map<String, dynamic> currency) async {
    final symbol = currency["symbol"];
    final exchanges = currency["exchanges"] as List;

    String exchange = exchanges != null ? exchanges.first : null;
    String blockchain = currency["blockchain"];
    String contractAddress = currency["contractAddress"];

    final existingAsset = await Asset.findOneBySymbol(symbol);
    if (existingAsset != null) {
      throw new Exception("Asset already exists");
    }

    if (exchange != null) {
      return AssetService.createAsset(symbol, exchange: exchange);
    } else {
      return AssetService.createAsset(
        symbol,
        blockchain: blockchain,
        contractAddress: contractAddress,
      );
    }
  }
}
