import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Asset, Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, NiceHashService, StorageService;
import "package:cryptarch/ui/widgets.dart";

class MiningPage extends StatefulWidget {
  @override
  _MiningPageState createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
  final assetService = AssetService();

  Map<String, Asset> assets;
  List<Miner> miners;
  double totalProfitability;

  @override
  void initState() {
    super.initState();
    this._getMiners();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              this.totalProfitability != null
                  ? "\$${this.totalProfitability.toStringAsFixed(2)}"
                  : "",
            ),
            Text(" / day", style: theme.textTheme.subtitle1),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMinerPage(),
                ),
              );
              await this._getMiners();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: this.miners != null
            ? this.miners.length > 0
                ? RefreshIndicator(
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    child: ListView.builder(
                      itemCount: miners.length,
                      itemBuilder: (BuildContext context, int index) {
                        final miner = miners[index];
                        final holding = miner.holding;
                        final currency = holding.currency.toUpperCase();
                        final asset = this.assets[currency];
                        final amount = holding.amount.toStringAsFixed(6);
                        final profitability = miner.profitability * asset.value;
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Card(
                            elevation: 1.0,
                            child: ListTile(
                              title: Text(miner.name),
                              // leading: Icon(Icons.circle),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("\$${profitability.toStringAsFixed(2)}"),
                                  Text(
                                    "$amount $currency",
                                    style: theme.textTheme.subtitle2,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                // TODO:
                                // await Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => AssetPage(
                                //       asset: item.asset,
                                //     ),
                                //   ),
                                // );
                                // await this._refreshMiners();
                              },
                            ),
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

  Future<void> _getMiners() async {
    final assets = await Asset.find();
    final assetLookup = Map<String, Asset>();
    for (Asset asset in assets) {
      assetLookup[asset.currency.toUpperCase()] = asset;
    }
    final miners = await Miner.find();
    final totalProfitability = miners.fold(0.0, (value, miner) {
      final asset = assetLookup[miner.holding.currency.toUpperCase()];
      return value + asset.value * miner.profitability;
    });

    setState(() {
      this.assets = assetLookup;
      this.miners = miners;
      this.totalProfitability = totalProfitability;
    });
  }

  Future<void> _refresh() async {
    await this.assetService.refreshPrices();
    for (Miner miner in this.miners) {
      if (miner.platform == "NiceHash") {
        final credentials = await StorageService.getItem("nicehash");
        if (credentials != null) {
          final nicehash = NiceHashService(
            organizationId: credentials["organization_id"],
            apiKey: credentials["api_key"],
            apiSecret: credentials["api_secret"],
          );
          await nicehash.refreshMiner(miner);
        }
      }
    }
    await this._getMiners();
  }
}
