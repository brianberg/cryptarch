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
        title: Row(
          children: [
            Text(totalValue),
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: CurrencyChange(
                value: this.totalValueChange,
                style: theme.textTheme.subtitle1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAccountPage(),
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
                    child: PortfolioList(
                      items: this.items,
                      onTap: (item) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetPage(
                              asset: item.asset,
                            ),
                          ),
                        );
                        await this._refreshItems();
                      },
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

    setState(() {
      this.items = items;
      this.totalValue = this.portfolio.calculateValue(items);
      this.totalValueChange = this.portfolio.calculateValueChange(items);
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._refreshItems();
  }
}
