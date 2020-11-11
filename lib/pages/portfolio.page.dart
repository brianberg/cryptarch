import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/pages/pages.dart";
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
    this._getItems().then((items) {
      setState(() {
        this.items = items;
        this.totalValue = items.fold(0, (value, item) {
          return value + item.value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.totalValue != null
            ? "\$${this.totalValue.toStringAsFixed(2)}"
            : "\..."),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              // TODO
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHoldingPage(),
                ),
              );
              final items = await this._getItems();
              setState(() {
                this.items = items;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: this.items != null
            ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  final amount = item.amount.toStringAsFixed(6);
                  final value = item.value.toStringAsFixed(2);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
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
                            final items = await this._getItems();
                            setState(() {
                              this.items = items;
                            });
                          }),
                    ),
                  );
                },
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<List<PortfolioItem>> _getItems() async {
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

    return items;
  }
}
