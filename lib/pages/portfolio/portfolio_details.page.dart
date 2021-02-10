import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Energy, Payout, Transaction;
import "package:cryptarch/services/services.dart" show PortfolioService;

import "package:cryptarch/widgets/widgets.dart";

class PortfolioDetailsPage extends StatefulWidget {
  static String routeName = "/portfolio_details";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => PortfolioDetailsPage(),
    );
  }

  @override
  _PortfolioDetailsPageState createState() => _PortfolioDetailsPageState();
}

class _PortfolioDetailsPageState extends State<PortfolioDetailsPage> {
  final portfolio = PortfolioService();

  // Total
  double totalValue;
  double totalSpent;
  double totalReturn;
  double totalROI;
  // Trades
  double tradesSpent;
  double tradesReturn;
  double tradesROI;
  // Mining
  double miningSpent;
  double miningReturn;
  double miningROI;

  @override
  void initState() {
    super.initState();
    this._initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fiatFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("Portfolio"),
      ),
      body: SafeArea(
        child: this.totalValue != null
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text("Total Value"),
                      trailing: Text(fiatFormat.format(this.totalValue)),
                    ),
                    ListTile(
                      title: const Text("Total Spent"),
                      trailing: Text(fiatFormat.format(this.totalSpent)),
                    ),
                    ListTile(
                      title: const Text("Total Return"),
                      trailing: Text(fiatFormat.format(this.totalReturn)),
                    ),
                    ListTile(
                      title: const Text("Total ROI"),
                      trailing: PercentChange(
                        value: this.totalROI,
                        style: theme.textTheme.subtitle2,
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Trades",
                            style: theme.textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text("Spent"),
                      trailing: Text(fiatFormat.format(this.tradesSpent)),
                    ),
                    ListTile(
                      title: const Text("Return"),
                      trailing: Text(fiatFormat.format(this.tradesReturn)),
                    ),
                    ListTile(
                      title: const Text("ROI"),
                      trailing: PercentChange(
                        value: this.tradesROI,
                        style: theme.textTheme.subtitle2,
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Mining",
                            style: theme.textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text("Spent"),
                      trailing: Text(fiatFormat.format(this.miningSpent)),
                    ),
                    ListTile(
                      title: const Text("Return"),
                      trailing: Text(fiatFormat.format(this.miningReturn)),
                    ),
                    ListTile(
                      title: const Text("ROI"),
                      trailing: PercentChange(
                        value: this.miningROI,
                        style: theme.textTheme.subtitle2,
                      ),
                    ),
                  ],
                ),
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _initialize() async {
    final totalValue = await this.portfolio.getValue();

    final transactions = await Transaction.find(
      filters: {
        "type": [Transaction.TYPE_BUY, Transaction.TYPE_SELL],
      },
    );

    double tradesReturn = 0.0;
    double tradesSpent = 0.0;
    if (transactions.isNotEmpty) {
      for (Transaction transaction in transactions) {
        switch (transaction.type) {
          case Transaction.TYPE_BUY:
            tradesReturn += transaction.returnValue;
            tradesSpent += transaction.total;
            break;
          case Transaction.TYPE_SELL:
            tradesReturn += transaction.returnValue;
            tradesSpent -= transaction.total;
            break;
        }
      }
    }

    final energyUsage = await Energy.find();
    final payouts = await Payout.find();

    // TODO: mining inventory
    double inventoryCost = 0;
    double energyCost = energyUsage.fold(0.0, (value, energy) {
      return value += energy.cost;
    });
    double payoutValue = payouts.fold(0.0, (value, payout) {
      return value += payout.value;
    });

    double miningSpent = inventoryCost + energyCost;
    double miningReturn = payoutValue;

    double totalSpent = tradesSpent + miningSpent;
    double totalReturn = totalValue - totalSpent;

    setState(() {
      this.totalValue = totalValue;
      this.totalSpent = totalSpent;
      this.totalReturn = totalReturn;
      this.totalROI = totalReturn / totalSpent * 100;
      this.tradesSpent = tradesSpent;
      this.tradesReturn = tradesReturn;
      this.tradesROI = tradesReturn / tradesSpent * 100;
      this.miningSpent = miningSpent;
      this.miningReturn = miningReturn;
      this.miningROI = miningReturn / miningSpent * 100;
    });
  }
}
