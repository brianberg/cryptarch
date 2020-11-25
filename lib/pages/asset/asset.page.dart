import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, Account;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

class AssetPage extends StatefulWidget {
  final Asset asset;

  AssetPage({
    Key key,
    @required this.asset,
  })  : assert(asset != null),
        super(key: key);

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  Asset asset;
  List<Account> accounts;

  @override
  void initState() {
    super.initState();
    this.asset = this.widget.asset;
    this._refreshAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final value = NumberFormat.simpleCurrency().format(this.asset.value);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.name,
              style: theme.textTheme.subtitle2,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: PercentChange(
                    value: this.asset.percentChange,
                    style: theme.textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: this.accounts != null
            ? RefreshIndicator(
                child: AccountList(
                  items: this.accounts,
                  onTap: (account) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAccountPage(account: account),
                      ),
                    );
                    await this._refreshAccounts();
                  },
                ),
                onRefresh: this._refresh,
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _refreshAccounts() async {
    final accounts = await Account.find(
      filters: {"assetId": this.asset.id},
    );
    setState(() {
      this.accounts = accounts;
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
