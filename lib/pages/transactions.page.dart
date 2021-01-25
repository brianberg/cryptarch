import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/services/services.dart"
    show AssetService, PortfolioService;
import "package:cryptarch/widgets/widgets.dart";

class TransactionsPage extends StatefulWidget {
  static const routeName = "/transactions";

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final portfolio = PortfolioService();

  List<Transaction> transactions;
  double totalReturn;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Return",
                  style: theme.textTheme.subtitle2,
                ),
                this.totalReturn != null
                    ? CurrencyChange(value: this.totalReturn)
                    : Text("..."),
              ],
            ),
          ],
        ),
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
                            builder: (context) => TransactionDetailPage(
                              transaction: transaction,
                            ),
                          ),
                        );
                        this._initialize();
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
    final totalReturn = await this.portfolio.getTotalReturn();

    setState(() {
      this.transactions = transactions;
      this.totalReturn = totalReturn ?? 0.0;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrices();
    await this._initialize();
  }
}
