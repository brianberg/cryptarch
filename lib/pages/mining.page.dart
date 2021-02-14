import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart"
    show AssetService, MiningService;
import "package:cryptarch/widgets/widgets.dart";

class MiningPage extends StatefulWidget {
  static const routeName = "/mining";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => MiningPage(),
    );
  }

  @override
  _MiningPageState createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
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
      appBar: FlatAppBar(
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
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              await Navigator.push(
                context,
                MinerAddPage.route(),
              );
              await this._getMiners();
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
                case "inventory":
                  Navigator.push(context, InventoryPage.route());
                  break;
                case "settings":
                  Navigator.push(context, SettingsPage.route());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: "refresh",
                child: Text("Refresh"),
              ),
              const PopupMenuItem<String>(
                value: "inventory",
                child: Text("Inventory"),
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
                          MinerDetailPage.route(miner),
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
    await AssetService.refreshPrices();
    await MiningService.refreshMiners(filters: {"active": 1});
    await this._getMiners();
  }
}
