import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Account;
import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

class AccountPage extends StatefulWidget {
  final Account account;

  AccountPage({
    Key key,
    @required this.account,
  })  : assert(account != null),
        super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account account;

  @override
  void initState() {
    super.initState();
    this.account = this.widget.account;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = this.account.asset.symbol;
    final amount = this.account.amount.toStringAsFixed(6);
    final value = NumberFormat.simpleCurrency().format(this.account.value);

    return Scaffold(
      appBar: FlatAppBar(
        title: Text(this.widget.account.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditAccountPage(account: this.widget.account),
                ),
              );
              await this._refreshAccount();
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
                            "Amount",
                            style: theme.textTheme.bodyText1,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("$amount $symbol"),
                              Text(
                                value,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Asset",
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
                  child: AssetListItem(
                    asset: this.account.asset,
                    onTap: (asset) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetPage(
                            asset: asset,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          onRefresh: this._refresh,
        ),
      ),
    );
  }

  Future<void> _refreshAccount() async {
    final account = await Account.findOneById(this.account.id);
    setState(() {
      this.account = account;
    });
  }

  Future<void> _refresh() async {
    await AssetService.refreshPrice(this.account.asset);
    await this._refreshAccount();
  }
}
