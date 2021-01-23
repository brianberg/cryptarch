import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

class TransactionsPage extends StatefulWidget {
  static const routeName = "/transactions";

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Transaction> transactions;
  double totalChange;

  @override
  void initState() {
    super.initState();
    this._initialize();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this._initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("Trades"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.add_circle,
              color: theme.accentColor,
            ),
            color: theme.cardTheme.color,
            onSelected: (String selected) async {
              switch (selected) {
                case "buy":
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                        type: Transaction.TYPE_BUY,
                      ),
                    ),
                  );
                  await this._initialize();
                  break;
                case "sell":
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                        type: Transaction.TYPE_SELL,
                      ),
                    ),
                  );
                  await this._initialize();
                  break;
                case "convert":
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                        type: Transaction.TYPE_CONVERT,
                      ),
                    ),
                  );
                  await this._initialize();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: "buy",
                child: Text("Buy"),
              ),
              const PopupMenuItem<String>(
                value: "sell",
                child: Text("Sell"),
              ),
              const PopupMenuItem<String>(
                value: "convert",
                child: Text("Convert"),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: this.transactions != null
            ? this.transactions.length > 0
                ? RefreshIndicator(
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surface,
                    child: TradeList(
                      trades: this.transactions,
                      onTap: (Transaction transaction) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TradePage(
                              trade: transaction,
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

  Future<void> _initialize() async {
    final transactions = await Transaction.find(orderBy: "date DESC");

    // double totalChange = transactions.fold(0, (value, asset) {
    //   return value + asset.percentChange;
    // });

    setState(() {
      this.transactions = transactions;
      // this.totalChange = totalChange;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._initialize();
  }
}
