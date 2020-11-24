import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, MiningService;
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

    final totalProfitability = this.totalProfitability != null
        ? NumberFormat.simpleCurrency().format(this.totalProfitability)
        : "";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(totalProfitability),
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
        return value + miner.fiatProfitability;
      }
      return value;
    });

    miners.sort((a, b) => 0 - a.profitability.compareTo(b.profitability));

    setState(() {
      this.miners = miners;
      this.totalProfitability = totalProfitability;
    });
  }

  Future<void> _refresh() async {
    await MiningService.refreshMiners(filters: {"active": 1});
    await this._getMiners();
  }
}
