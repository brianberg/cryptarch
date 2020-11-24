import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, Account;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/ui/widgets.dart";

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
  List<Account> accounts;

  @override
  void initState() {
    super.initState();
    this._refreshaccounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asset = this.widget.asset;
    final value = NumberFormat.simpleCurrency().format(asset.value);
    final changePrefix = asset.percentChange > 0 ? '+' : '';
    final percentChange = "${asset.percentChange.toStringAsFixed(2)}%";

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
                Text(
                  " $changePrefix$percentChange",
                  style: theme.textTheme.subtitle1,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: this.accounts != null
            ? AccountList(
                items: this.accounts,
                onTap: (account) async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccountPage(account: account),
                    ),
                  );
                  await this._refreshaccounts();
                },
              )
            : LoadingIndicator(),
      ),
    );
  }

  Future<void> _refreshaccounts() async {
    Map<String, dynamic> accountFilters = {};
    accountFilters["assetId"] = this.widget.asset.id;
    final accounts = await Account.find(filters: accountFilters);
    setState(() {
      this.accounts = accounts;
    });
  }
}
