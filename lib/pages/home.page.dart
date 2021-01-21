import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Asset, Settings;
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
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
  double portfolioValueChange;

  @override
  void initState() {
    super.initState();
    this._initialize();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this._initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final portfolioValue = this.portfolioValue != null
        ? NumberFormat.simpleCurrency().format(this.portfolioValue)
        : null;

    return Scaffold(
      appBar: FlatAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Portfolio",
                  style: theme.textTheme.subtitle2,
                ),
                this.portfolioValue != null
                    ? Row(
                        children: [
                          Text(portfolioValue),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: CurrencyChange(
                              value: this.portfolioValueChange,
                              style: theme.textTheme.subtitle1,
                            ),
                          ),
                        ],
                      )
                    : Text("..."),
              ],
            ),
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
    final assets = await Asset.find(
      filters: {
        "type": "!= ${Asset.TYPE_FIAT}",
      },
      orderBy: "value DESC",
    );
    final value = await this.portfolio.getValue();
    final valueChange = await this.portfolio.getValueChange();

    setState(() {
      this.assets = assets;
      this.portfolioValue = value;
      this.portfolioValueChange = valueChange;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._initialize();
  }
}
