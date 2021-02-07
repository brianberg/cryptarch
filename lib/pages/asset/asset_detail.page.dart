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
  double returnValue;

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

    final assetValue = fiatFormat.format(this.asset.value);
    final portfolioValue = this.portfolioValue != null
        ? fiatFormat.format(this.portfolioValue)
        : "...";

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            this.asset.name,
                            style: theme.textTheme.subtitle2,
                          ),
                          Text(assetValue, style: theme.textTheme.headline6),
                          PercentChange(
                            value: this.asset.percentChange,
                            style: theme.textTheme.subtitle1,
                          ),
                        ],
                      ),
                      AssetIcon(asset: this.asset),
                    ],
                  ),
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
                        style: theme.textTheme.bodyText1,
                      ),
                      Text(portfolioValue)
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
                        style: theme.textTheme.bodyText1,
                      ),
                      this.returnValue != null
                          ? CurrencyChange(value: this.returnValue)
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

    final returnValue = transactions.isNotEmpty
        ? transactions.fold(0.0, (value, transaction) {
            return value += transaction.returnValue;
          })
        : null;

    setState(() {
      this.accounts = accounts;
      this.transactions = transactions;
      this.portfolioValue = portfolioValue;
      this.returnValue = returnValue;
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
