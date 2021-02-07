import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/widgets/widgets.dart";

class PortfolioPage extends StatefulWidget {
  static const routeName = "/portfolio";

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final portfolio = PortfolioService();

  List<PortfolioItem> items;
  double totalValue;
  double totalValueChange;

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

    final totalValue = this.totalValue != null
        ? NumberFormat.simpleCurrency().format(this.totalValue)
        : "";

    return Scaffold(
      appBar: FlatAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Value",
              style: theme.textTheme.subtitle2,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(totalValue),
                this.totalValueChange != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: CurrencyChange(
                          value: this.totalValueChange,
                          style: theme.textTheme.subtitle1,
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
    final totalValue = this.portfolio.calculateValue(items);
    final totalValueChange = this.portfolio.calculateValueChange(items);

    setState(() {
      this.items = items;
      this.totalValue = totalValue;
      this.totalValueChange = totalValueChange;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._refreshItems();
  }
}
