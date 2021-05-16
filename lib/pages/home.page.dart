import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, PortfolioItem;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/widgets/widgets.dart";

class HomePage extends StatefulWidget {
  static const routeName = "/";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => HomePage(),
    );
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final portfolio = PortfolioService();

  List<PortfolioItem> items;
  List<Asset> topAssets;

  double portfolioValue;
  double portfolioValueChange;
  double portfolioPercentChange;

  @override
  void initState() {
    super.initState();
    this._refreshItems();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this._refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final portfolioValue = this.portfolioValue != null
        ? NumberFormat.simpleCurrency().format(this.portfolioValue)
        : "";

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("Portfolio"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: theme.accentColor,
            ),
            onPressed: () async {
              await Navigator.push(context, AccountAddPage.route());
              await this._refreshItems();
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            color: theme.cardTheme.color,
            onSelected: (String selected) async {
              switch (selected) {
                case "refresh":
                  await this._refresh();
                  break;
                case "settings":
                  Navigator.push(context, SettingsPage.route());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: "refresh",
                child: Text("Refresh"),
              ),
              const PopupMenuItem<String>(
                value: "settings",
                child: Text("Settings"),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: this.items != null
            ? RefreshIndicator(
                color: theme.colorScheme.onSurface,
                backgroundColor: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: InkWell(
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Balance",
                                      style: theme.textTheme.subtitle2,
                                    ),
                                    Text(
                                      portfolioValue,
                                      style: theme.textTheme.headline6,
                                    ),
                                    this.portfolioValueChange != null
                                        ? CurrencyChange(
                                            value: this.portfolioValueChange,
                                            duration: const Duration(days: 1),
                                            style: theme.textTheme.subtitle2,
                                          )
                                        : Container(),
                                  ],
                                ),
                                this.portfolioPercentChange != null
                                    ? Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PercentChange(
                                            value: this.portfolioPercentChange,
                                            style: theme.textTheme.subtitle2,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context, PortfolioDetailPage.route());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Top Assets",
                              style: theme.textTheme.headline6,
                            ),
                          ],
                        ),
                      ),
                      this.topAssets.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  children: this.topAssets.map((asset) {
                                    return AssetCardItem(
                                      asset: asset,
                                      onTap: (asset) async {
                                        await Navigator.push(
                                          context,
                                          AssetDetailPage.route(asset),
                                        );
                                        await this._refreshItems();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 96.0,
                              child: Container(
                                child: Center(
                                  child: Text("No Assets"),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Your Assets",
                              style: theme.textTheme.headline6,
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 96.0,
                                  child: Text(
                                    "Price",
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.subtitle2,
                                  ),
                                ),
                                SizedBox(
                                  width: 96.0,
                                  child: Text(
                                    "Holding",
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.subtitle2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      this.items.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: PortfolioList(
                                items: this.items,
                                onTap: (item) async {
                                  await Navigator.push(
                                    context,
                                    AssetDetailPage.route(item.asset),
                                  );
                                  await this._refreshItems();
                                },
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 96.0,
                              child: Container(
                                child: Center(
                                  child: Text("No Items"),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                onRefresh: this._refresh,
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _refreshItems() async {
    final items = await this.portfolio.getItems();
    final portfolioValue = this.portfolio.calculateValue(items);
    final portfolioValueChange = this.portfolio.calculateValueChange(items);
    final portfolioPercentChange = this.portfolio.calculatePercentChange(items);

    final topAssets = await Asset.find(
      filters: {
        "type": "!= ${Asset.TYPE_FIAT}",
      },
      orderBy: "percentChange DESC",
      limit: 10,
    );

    setState(() {
      this.items = items;
      this.portfolioValue = portfolioValue;
      this.portfolioValueChange = portfolioValueChange;
      this.portfolioPercentChange = portfolioPercentChange;
      this.topAssets = topAssets;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._refreshItems();
  }
}
