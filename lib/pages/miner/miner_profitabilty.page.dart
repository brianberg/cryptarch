import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Energy, Miner, Payout;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/widgets/widgets.dart";

class MinerProfitabilityPage extends StatefulWidget {
  final Miner miner;

  MinerProfitabilityPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _MinerProfitabilityPageState createState() => _MinerProfitabilityPageState();
}

class _MinerProfitabilityPageState extends State<MinerProfitabilityPage> {
  String duration = DurationChips.DURATION_7D;
  Map<String, dynamic> filters;

  double totalProfit;
  double totalFiatProfit;
  double totalEnergyUsage;
  double totalEnergyCost;
  double actualProfitability;
  double actualFiatProfitability;

  @override
  void initState() {
    super.initState();
    this._initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final miner = this.widget.miner;
    final symbol = miner.asset.symbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profitability"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: this.filters == null
              ? LoadingIndicator()
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: MinerProfitChart(
                        filters: this.filters,
                        showCheckboxes: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DurationChips(
                        selected: this.duration,
                        onSelected: (duration) {
                          this.setState(() {
                            this.duration = duration;
                            this.filters = this._getDurationFilters();
                          });
                          this._initialize();
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Reported",
                        style: theme.textTheme.bodyText1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "${miner.profitability.toStringAsFixed(6)} $symbol"),
                          Text(
                            "${this._formatFiat(miner.fiatProfitability)} / day",
                            style: theme.textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Actual",
                        style: theme.textTheme.bodyText1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "${this.actualProfitability.toStringAsFixed(6)} $symbol"),
                          Text(
                            "${this._formatFiat(this.actualFiatProfitability)} / day",
                            style: theme.textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                        title: Text(
                          "Profit",
                          style: theme.textTheme.bodyText1,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                "${this.totalProfit.toStringAsFixed(6)} $symbol"),
                            Text(
                              "${this._formatFiat(this.totalFiatProfit)}",
                              style: theme.textTheme.subtitle2,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MinerPayoutsPage(
                                miner: this.widget.miner,
                              ),
                            ),
                          );
                        }),
                    ListTile(
                      title: Text(
                        "Energy",
                        style: theme.textTheme.bodyText1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              "${this.totalEnergyUsage.toStringAsFixed(3)} kWh"),
                          Text(
                            "${this._formatFiat(this.totalEnergyCost)}",
                            style: theme.textTheme.subtitle2,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinerEnergyUsagePage(
                              miner: this.widget.miner,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    final filters = this._getDurationFilters();
    final payouts = await Payout.find(filters: filters);
    final energyUsage = await Energy.find(filters: filters);

    final Map<DateTime, Energy> energyLookup = {};
    for (Energy energy in energyUsage) {
      energyLookup[energy.date] = energy;
    }

    double totalProfit = 0.0;
    double totalFiatProfit = 0.0;
    double totalEnergyUsage = 0.0;
    double totalEnergyCost = 0.0;

    for (Payout payout in payouts) {
      final energy = energyLookup[payout.date];
      totalProfit += payout.amount;
      if (energy != null) {
        totalFiatProfit += payout.value - energy.cost;
        totalEnergyUsage += energy.amount;
        totalEnergyCost += energy.cost;
      }
    }

    setState(() {
      this.filters = filters;
      this.totalProfit = totalProfit;
      this.totalFiatProfit = totalFiatProfit;
      this.totalEnergyUsage = totalEnergyUsage;
      this.totalEnergyCost = totalEnergyCost;
      this.actualProfitability = totalProfit / payouts.length;
      this.actualFiatProfitability = totalFiatProfit / payouts.length;
    });
  }

  String _formatFiat(double fiat) {
    return NumberFormat.simpleCurrency().format(fiat);
  }

  Map<String, dynamic> _getDurationFilters() {
    Map<String, dynamic> filters = {"minerId": this.widget.miner.id};
    if (this.duration != DurationChips.DURATION_ALL) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      switch (this.duration) {
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
