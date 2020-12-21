import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Asset, Miner, Settings;
import "package:cryptarch/services/services.dart"
    show AssetService, MiningService, PortfolioService;
import "package:cryptarch/widgets/widgets.dart";

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
  final portfolio = PortfolioService();

  List<Asset> assets;
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

    final portfolioValue = this.portfolioValue != null
        ? NumberFormat.simpleCurrency().format(this.portfolioValue)
        : null;
    final miningProfitability = this.miningProfitability != null
        ? NumberFormat.simpleCurrency().format(this.miningProfitability)
        : null;

    return Scaffold(
      appBar: FlatAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Portfolio",
                  style: theme.textTheme.subtitle2,
                ),
                Text(portfolioValue != null ? portfolioValue : "..."),
              ],
            ),
            this.widget.settings.showMining
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mining",
                        style: theme.textTheme.subtitle2,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(miningProfitability != null
                              ? miningProfitability
                              : "..."),
                          Text(" / day", style: theme.textTheme.subtitle1),
                        ],
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
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
                        await this._refresh();
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
    final assets = await Asset.find(orderBy: "value DESC");
    final value = await this.portfolio.getValue();

    double miningProfitability;
    if (settings.showMining) {
      miningProfitability = await MiningService.getProfitability();
    }

    setState(() {
      this.assets = assets;
      this.portfolioValue = value;
      this.miningProfitability = miningProfitability;
    });
  }

  Future<void> _refresh() async {
    final settings = this.widget.settings;
    await AssetService.refreshPrices();
    if (settings.showMining) {
      await MiningService.refreshMiners(filters: {"active": 1});
    }
    await this._initialize();
  }
}
