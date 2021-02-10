import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/widgets/widgets.dart";

class HomePage extends StatefulWidget {
  static const routeName = "/";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final portfolio = PortfolioService();

  List<PortfolioItem> items;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Portfolio",
              style: theme.textTheme.subtitle2,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: theme.accentColor,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountAddPage(),
                ),
              );
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
            ? this.items.length > 0
                ? RefreshIndicator(
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          PortfolioList(
                            items: this.items,
                            onTap: (item) async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AssetDetailPage(
                                    asset: item.asset,
                                  ),
                                ),
                              );
                              await this._refreshItems();
                            },
                          )
                        ],
                      ),
                    ),
                    onRefresh: this._refresh,
                  )
                : Center(child: const Text("Empty"))
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _refreshItems() async {
    final items = await this.portfolio.getItems();
    final portfolioValue = this.portfolio.calculateValue(items);
    final portfolioValueChange = this.portfolio.calculateValueChange(items);

    setState(() {
      this.items = items;
      this.portfolioValue = portfolioValue;
      this.portfolioValueChange = portfolioValueChange;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._refreshItems();
  }
}
