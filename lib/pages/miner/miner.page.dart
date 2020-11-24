import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show MiningService;
import "package:cryptarch/ui/widgets.dart";

class MinerPage extends StatefulWidget {
  final Miner miner;

  MinerPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _MinerPageState createState() => _MinerPageState();
}

class _MinerPageState extends State<MinerPage> {
  Miner miner;

  @override
  void initState() {
    super.initState();
    this.miner = this.widget.miner;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = this.miner.asset.symbol;
    final profitability = this.miner.profitability.toStringAsFixed(6);
    final unpaidAmount = this.miner.unpaidAmount.toStringAsFixed(6);
    final fiatUnpaidAmount =
        NumberFormat.simpleCurrency().format(this.miner.fiatUnpaidAmount);
    final fiatProfitability =
        NumberFormat.simpleCurrency().format(this.miner.fiatProfitability);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.miner.name),
        bottom: this.miner.active
            ? null
            : AppBar(
                toolbarHeight: 40.0,
                centerTitle: true,
                title: Text(
                  "Inactive",
                  style: theme.textTheme.bodyText1,
                ),
                leading: Container(),
                backgroundColor: theme.colorScheme.surface,
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMinerPage(miner: this.widget.miner),
                ),
              );
              await this._refreshMiner();
            },
          )
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Profitability",
                            style: theme.textTheme.bodyText1,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("$profitability $symbol"),
                              Text(
                                "$fiatProfitability / day",
                                style: theme.textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Unpaid",
                            style: theme.textTheme.bodyText1,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("$unpaidAmount $symbol"),
                              Text(
                                fiatUnpaidAmount,
                                style: theme.textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Asset",
                  style: theme.textTheme.bodyText1,
                ),
              ),
              AssetListItem(asset: this.miner.asset),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Wallet",
                  style: theme.textTheme.bodyText1,
                ),
              ),
              AccountListItem(
                account: this.miner.account,
              ),
            ],
          ),
          onRefresh: this._refresh,
        ),
      ),
    );
  }

  Future<void> _refreshMiner() async {
    final miner = await Miner.findOneById(this.miner.id);
    setState(() {
      this.miner = miner;
    });
  }

  Future<void> _refresh() async {
    final miner = await MiningService.refreshMiner(this.miner);
    setState(() {
      this.miner = miner;
    });
  }
}
