import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/ui/widgets.dart";

class AssetPage extends StatefulWidget {
  final Asset asset;

  AssetPage({
    Key key,
    @required this.asset,
  })  : assert(asset != null),
        super(key: key);

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  List<Holding> holdings;

  @override
  void initState() {
    super.initState();
    this._getHoldings().then((holdings) {
      setState(() {
        this.holdings = holdings;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> holdingFilters = {};
    holdingFilters["currency"] = this.widget.asset.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.asset.name),
      ),
      body: SafeArea(
        child: this.holdings != null
            ? HoldingList(
                items: this.holdings,
                onTap: (holding) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditHoldingPage(holding: holding),
                    ),
                  );
                },
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<List<Holding>> _getHoldings() {
    Map<String, dynamic> holdingFilters = {};
    holdingFilters["currency"] = this.widget.asset.currency;
    return Holding.find(filters: holdingFilters);
  }
}
