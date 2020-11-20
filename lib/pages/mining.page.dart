import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, EthermineService, NiceHashService;
import "package:cryptarch/ui/widgets.dart";

class MiningPage extends StatefulWidget {
  static const routeName = "/mining";

  @override
  _MiningPageState createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
  final assetService = AssetService();

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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              this.totalProfitability != null
                  ? "\$${this.totalProfitability.toStringAsFixed(2)}"
                  : "",
            ),
            Text(
              " / day",
              style: theme.textTheme.subtitle1,
            ),
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
                    child: MinerList(
                      items: this.miners,
                      onTap: (Miner miner) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinerPage(
                              miner: miner,
                            ),
                          ),
                        );
                        await this._getMiners();
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
    final miners = await Miner.find();
    final totalProfitability = miners.fold(0.0, (value, miner) {
      if (miner.active) {
        return value + miner.calculateFiatProfitability();
      }
      return value;
    });

    setState(() {
      this.miners = miners;
      this.totalProfitability = totalProfitability;
    });
  }

  Future<void> _refresh() async {
    await this.assetService.refreshPrices();
    for (Miner miner in this.miners) {
      if (!miner.active) continue;
      if (miner.platform == "Ethermine") {
        final ethermine = EthermineService();
        await ethermine.refreshMiner(miner);
      } else if (miner.platform == "NiceHash") {
        final nicehash = NiceHashService();
        await nicehash.refreshMiner(miner);
      }
    }
    await this._getMiners();
  }
}
