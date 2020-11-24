import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show PortfolioItem;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/ui/widgets.dart";

class PortfolioPage extends StatefulWidget {
  static const routeName = "/portfolio";

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final assetService = AssetService();
  final portfolio = PortfolioService();

  List<PortfolioItem> items;
  double totalValue;

  @override
  void initState() {
    super.initState();
    this._refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalValue = this.totalValue != null
        ? NumberFormat.simpleCurrency().format(this.totalValue)
        : "";

    return Scaffold(
      appBar: AppBar(
        title: Text(totalValue),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
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
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items[index];
                        final amount = item.amount.toStringAsFixed(6);
                        final value =
                            NumberFormat.simpleCurrency().format(item.value);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            16.0,
                            16.0,
                            0.0,
                          ),
                          child: ListTile(
                              title: Text(
                                item.asset.name,
                                style: TextStyle(
                                  color: theme.textTheme.bodyText1.color,
                                ),
                              ),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 32.0,
                                    width: 32.0,
                                    child: AssetIcon(asset: item.asset),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(value),
                                  Text(
                                    "$amount ${item.asset.symbol}",
                                    style: theme.textTheme.subtitle2,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssetPage(
                                      asset: item.asset,
                                    ),
                                  ),
                                );
                                await this._refreshItems();
                              }),
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

  Future<void> _refreshItems() async {
    final items = await this.portfolio.getItems();

    setState(() {
      this.items = items;
      this.totalValue = this.portfolio.calculateValue(items);
    });
  }

  Future<void> _refresh() async {
    await this.assetService.refreshPrices();
    await this._refreshItems();
  }
}
