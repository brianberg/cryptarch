import "dart:ui";

import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, Account, Transaction;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

class AssetDetailPage extends StatefulWidget {
  final Asset asset;

  AssetDetailPage({
    Key key,
    @required this.asset,
  })  : assert(asset != null),
        super(key: key);

  @override
  _AssetDetailPageState createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  Asset asset;
  List<Account> accounts;
  List<Transaction> transactions;
  double portfolioValue;
  double portfolioAmount;
  double returnValue;
  double totalSpent;

  @override
  void initState() {
    super.initState();
    this.asset = this.widget.asset;
    this._refreshAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fiatFormat = NumberFormat.simpleCurrency();

    final portfolioValue = this.portfolioValue != null
        ? fiatFormat.format(this.portfolioValue)
        : "...";

    final returnOnInvestment = this.returnValue != null
        ? this.returnValue / this.totalSpent * 100
        : null;

    return Scaffold(
      appBar: FlatAppBar(
        title: Text(this.asset.symbol),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AssetDetailItem(asset: asset),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Accounts",
                        style: theme.textTheme.headline6,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            portfolioValue,
                            style: theme.textTheme.bodyText1,
                          ),
                          Text(
                            "$portfolioAmount ${asset.symbol}",
                            style: theme.textTheme.subtitle2.copyWith(
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                this.accounts != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 0.0,
                          child: AccountList(
                            items: this.accounts,
                            onTap: (account) async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountDetailPage(
                                    account: account,
                                  ),
                                ),
                              );
                              await this._refreshAccounts();
                            },
                          ),
                        ),
                      )
                    : LoadingIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions",
                        style: theme.textTheme.headline6,
                      ),
                      this.returnValue != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CurrencyChange(
                                  value: this.returnValue,
                                  style: theme.textTheme.headline6,
                                ),
                                PercentChange(
                                  value: returnOnInvestment,
                                  style: theme.textTheme.subtitle2.copyWith(
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                this.transactions != null
                    ? TransactionList(
                        items: this.transactions,
                        onTap: (transaction) async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailPage(
                                transaction: transaction,
                              ),
                            ),
                          );
                          await this._refreshAccounts();
                        },
                      )
                    : LoadingIndicator()
              ],
            ),
          ),
          onRefresh: this._refresh,
        ),
      ),
    );
  }

  Future<void> _refreshAccounts() async {
    final accounts = await Account.find(filters: {
      "assetId": this.asset.id,
    });
    final receivedTxs = await Transaction.find(filters: {
      "receivedAssetId": this.asset.id,
    });
    final sentTxs = await Transaction.find(filters: {
      "sentAssetId": this.asset.id,
    });
    final transactions = [...receivedTxs, ...sentTxs];
    transactions.sort((a, b) => a.date.compareTo(b.date));

    final portfolioValue = accounts.fold(0.0, (value, account) {
      return value += account.value;
    });
    final portfolioAmount = accounts.fold(0.0, (value, account) {
      return value += account.amount;
    });

    double returnValue;
    double totalSpent;
    if (transactions.isNotEmpty) {
      returnValue = transactions.fold(0.0, (value, transaction) {
        return value += transaction.returnValue;
      });
      totalSpent = transactions.fold(0.0, (value, transaction) {
        switch (transaction.type) {
          case Transaction.TYPE_BUY:
            value += transaction.total;
            break;
          case Transaction.TYPE_SELL:
            value -= transaction.total;
            break;
        }
        return value;
      });
    }

    setState(() {
      this.accounts = accounts;
      this.transactions = transactions;
      this.portfolioValue = portfolioValue;
      this.portfolioAmount = portfolioAmount;
      this.returnValue = returnValue;
      this.totalSpent = totalSpent;
    });
  }

  Future<void> _refreshPrice() async {
    final asset = await AssetService.refreshPrice(this.asset);
    setState(() {
      this.asset = asset;
    });
  }

  Future<void> _refresh() async {
    await this._refreshPrice();
    await this._refreshAccounts();
  }
}
