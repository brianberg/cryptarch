import 'package:cryptarch/services/markets.service.dart';
import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show MarketsService;
import "package:cryptarch/ui/widgets.dart";

class PortfolioItem {
  final Asset asset;
  final List<Holding> holdings;

  PortfolioItem({
    @required this.asset,
    @required this.holdings,
  })  : assert(asset != null),
        assert(holdings != null);

  double get amount {
    if (this.holdings.isEmpty) {
      return 0;
    }
    final amounts = this.holdings.map((h) => h.amount);
    return amounts.reduce((value, amount) {
      return value + amount;
    });
  }

  double get value {
    return this.amount * this.asset.value;
  }
}

class PortfolioPage extends StatefulWidget {
  static const routeName = "/";

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(this.totalValue != null
            ? "\$${this.totalValue.toStringAsFixed(2)}"
            : ""),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHoldingPage(),
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
                    color: theme.colorScheme.onSecondary,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items[index];
                        final amount = item.amount.toStringAsFixed(6);
                        final value = item.value.toStringAsFixed(2);
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Card(
                            elevation: 1.0,
                            child: ListTile(
                                title: Text(item.asset.name),
                                leading: Icon(Icons.circle),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("\$$value"),
                                    Text(
                                      "$amount ${item.asset.currency}",
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
                          ),
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
    final List<PortfolioItem> items = [];
    final assets = await Asset.find();
    for (Asset asset in assets) {
      Map<String, dynamic> holdingFilters = {};
      holdingFilters["currency"] = asset.currency;
      final item = PortfolioItem(
        asset: asset,
        holdings: await Holding.find(filters: holdingFilters),
      );
      items.add(item);
    }

    items.sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      this.items = items;
      this.totalValue = items.fold(0, (value, item) {
        return value + item.value;
      });
    });
  }

  Future<void> _refreshPrices() async {
    final markets = MarketsService();
    final assets = await Asset.find();
    for (Asset asset in assets) {
      if (asset.tokenPlatform != null) {
        final price = await markets.getTokenPrice(
          asset.tokenPlatform,
          asset.contractAddress,
          "USD",
        );
        if (price != null) {
          asset.value = price;
          await asset.save();
        }
      } else {
        final ticker = "${asset.currency}/USD";
        final price = await markets.getPrice(ticker, asset.exchange);
        if (price != null) {
          asset.value = price;
          await asset.save();
        }
      }
    }
  }

  Future<void> _refresh() async {
    await this._refreshPrices();
    await this._refreshItems();
  }
}
