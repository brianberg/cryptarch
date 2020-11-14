import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/ui/widgets.dart";

class HomePage extends StatefulWidget {
  static const routeName = "/";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final assetService = AssetService();
  final portfolio = PortfolioService();

  List<Asset> assets;
  double portfolioValue;

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
          this.portfolioValue != null
              ? "\$${this.portfolioValue.toStringAsFixed(2)}"
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
                      onTap: (asset) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetPage(
                              asset: asset,
                            ),
                          ),
                        );
                        await this._refreshPortfolio();
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
    final value = await this.portfolio.getValue();

    setState(() {
      this.assets = assets;
      this.portfolioValue = value;
    });
  }

  Future<void> _refreshPortfolio() async {
    final value = await this.portfolio.getValue();

    setState(() {
      this.portfolioValue = value;
    });
  }

  Future<void> _refresh() async {
    await this.assetService.refreshPrices();
    await this._initialize();
  }
}
