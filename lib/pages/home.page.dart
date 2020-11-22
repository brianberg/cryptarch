import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Asset, Miner, Settings;
import "package:cryptarch/services/services.dart"
    show AssetService, EthermineService, NiceHashService, PortfolioService;
import "package:cryptarch/ui/widgets.dart";

class HomePage extends StatefulWidget {
  static const routeName = "/";

  final Settings settings;

  HomePage({
    Key key,
    @required this.settings,
  })  : assert(settings != null),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final assetService = AssetService();
  final portfolio = PortfolioService();

  List<Asset> assets;
  List<Miner> miners;
  double portfolioValue;
  double miningProfitability;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              this.portfolioValue != null
                  ? "\$${this.portfolioValue.toStringAsFixed(2)}"
                  : "",
            ),
            this.miningProfitability != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("\$${this.miningProfitability.toStringAsFixed(2)}"),
                      Text(" / day", style: theme.textTheme.subtitle1),
                    ],
                  )
                : Text(""),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, SettingsPage.routeName);
              await this._initialize();
            },
          )
        ],
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
    final settings = this.widget.settings;
    final assets = await Asset.find();
    final value = await this.portfolio.getValue();

    double miningProfitability;

    if (settings.showMining) {
      final miners = await Miner.find();

      miningProfitability = miners.fold(0.0, (value, miner) {
        if (miner.active) {
          return value + miner.fiatProfitability;
        }
        return value;
      });
    }

    setState(() {
      this.assets = assets;
      this.miners = miners;
      this.portfolioValue = value;
      this.miningProfitability = miningProfitability;
    });
  }

  Future<void> _refreshPortfolio() async {
    final value = await this.portfolio.getValue();

    setState(() {
      this.portfolioValue = value;
    });
  }

  Future<void> _refreshMiners() async {
    for (Miner miner in this.miners) {
      if (!miner.active) continue;
      if (miner.platform == "Ethermine") {
        final ethermine = EthermineService();
        await ethermine.refreshMiner(miner);
      } else if (miner.platform == "NiceHash") {
        final nicehash = NiceHashService();
        await nicehash.refreshMiner(miner);
      }
    }
  }

  Future<void> _refresh() async {
    final settings = this.widget.settings;
    await this.assetService.refreshPrices();
    if (settings.showMining) {
      await this._refreshMiners();
    }
    await this._initialize();
  }
}
