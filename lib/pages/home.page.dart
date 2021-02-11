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
        title: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Portfolio",
                style: theme.textTheme.subtitle2.copyWith(
                  color: theme.textTheme.bodyText1.color,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(portfolioValue),
                  this.portfolioValueChange != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: CurrencyChange(
                            value: this.portfolioValueChange,
                            style: theme.textTheme.subtitle1,
                            duration: const Duration(days: 1),
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(context, PortfolioDetailPage.route());
          },
        ),
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
                  Navigator.pushNamed(context, SettingsPage.routeName);
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Portfolio",
                              style: theme.textTheme.headline6,
                            ),
                          ],
                        ),
                      ),
                      this.items.isNotEmpty
                          ? PortfolioList(
                              items: this.items,
                              onTap: (item) async {
                                await Navigator.push(
                                  context,
                                  AssetDetailPage.route(item.asset),
                                );
                                await this._refreshItems();
                              },
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
      this.topAssets = topAssets;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._refreshItems();
  }
}
