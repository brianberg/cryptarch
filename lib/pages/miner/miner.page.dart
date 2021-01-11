import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Miner, Payout;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show MiningService;
import "package:cryptarch/widgets/widgets.dart";

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
  String payoutDuration = DurationChips.DURATION_7D;

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
      appBar: FlatAppBar(
        title: Text(this.widget.miner.name),
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
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.add_circle,
              color: theme.accentColor,
            ),
            color: theme.cardTheme.color,
            onSelected: (String selected) async {
              switch (selected) {
                case "energy":
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEnergyPage(miner: this.widget.miner),
                    ),
                  );
                  await this._refreshMiner();
                  break;
                case "payout":
                  // TODO:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: "energy",
                child: Text("Energy"),
              ),
              const PopupMenuItem<String>(
                value: "payout",
                child: Text("Payout"),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          child: ListView(
            children: [
              this.miner.active
                  ? Container()
                  : SizedBox(
                      width: double.infinity,
                      child: Container(
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Inactive"),
                            ],
                          ),
                        ),
                      ),
                    ),
              ListTile(
                title: Text(
                  "Profitability",
                  style: theme.textTheme.bodyText1,
                ),
                trailing: Column(
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
                onTap: () {
                  // TODO:
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MinerProfitChart(
                  filters: this._getPayoutFilters(),
                  showCost: false,
                  showRevenue: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: DurationChips(
                  selected: this.payoutDuration,
                  onSelected: (duration) {
                    this.setState(() {
                      this.payoutDuration = duration;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text(
                      "View Payouts",
                      style: theme.textTheme.button,
                    ),
                    color: theme.buttonColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MinerPayoutsPage(
                            miner: this.miner,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "Account",
                  style: theme.textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: AccountListItem(
                    account: this.miner.account,
                    onTap: (account) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountPage(
                            account: this.miner.account,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Unpaid",
                  style: theme.textTheme.bodyText1,
                ),
                trailing: Column(
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
              ),
              SizedBox(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Delete"),
                  textColor: Colors.red,
                  onPressed: () async {
                    try {
                      await this.miner.account.delete();
                      await Payout.deleteMany({"minerId": this.miner.id});
                      await this.miner.delete();
                      Navigator.pop(context);
                    } catch (err) {
                      // final snackBar = SnackBar(
                      //   content: Text(err.message),
                      // );
                      // Scaffold.of(context).showSnackBar(snackBar);
                      print(err);
                    }
                  },
                ),
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

  Map<String, dynamic> _getPayoutFilters() {
    Map<String, dynamic> filters = {"minerId": this.miner.id};
    if (this.payoutDuration != DurationChips.DURATION_ALL) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      switch (this.payoutDuration) {
        case DurationChips.DURATION_7D:
          final lastWeek = today.subtract(Duration(days: 7));
          filters["date"] = "> ${lastWeek.millisecondsSinceEpoch}";
          break;
        case DurationChips.DURATION_30D:
          final lastMonth = today.subtract(Duration(days: 30));
          filters["date"] = "> ${lastMonth.millisecondsSinceEpoch}";
          break;
        case DurationChips.DURATION_90D:
          final lastQuarter = today.subtract(Duration(days: 90));
          filters["date"] = "> ${lastQuarter.millisecondsSinceEpoch}";
          break;
        case DurationChips.DURATION_1Y:
          final lastYear = today.subtract(Duration(days: 365));
          filters["date"] = "> ${lastYear.millisecondsSinceEpoch}";
          break;
      }
    }

    return filters;
  }
}
