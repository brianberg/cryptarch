import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/ui/widgets.dart";

class PricesPage extends StatefulWidget {
  static const routeName = "/prices";

  @override
  _PricesPageState createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  final assetService = AssetService();

  List<Asset> assets;
  double totalChange;

  @override
  void initState() {
    super.initState();
    this._initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.totalChange != null
              ? "${this.totalChange > 0 ? '+' : ''}${this.totalChange.toStringAsFixed(2)}%"
              : "",
        ),
      ),
      body: SafeArea(
        child: this.assets != null
            ? this.assets.length > 0
                ? RefreshIndicator(
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    child: AssetList(
                      items: this.assets,
                      onTap: (Asset asset) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetPage(
                              asset: asset,
                            ),
                          ),
                        );
                      },
                    ),
                    onRefresh: this._refresh,
                  )
                : Center(child: const Text("Empty"))
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _initialize() async {
    final assets = await Asset.find();

    double totalChange = assets.fold(0, (value, asset) {
      return value + asset.percentChange;
    });

    setState(() {
      this.assets = assets;
      this.totalChange = totalChange;
    });
  }

  Future<void> _refresh() async {
    await this.assetService.refreshPrices();
    await this._initialize();
  }
}
