import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Account;

class AccountListItem extends StatelessWidget {
  final Account account;
  final Function onTap;

  AccountListItem({
    Key key,
    @required this.account,
    this.onTap,
  })  : assert(account != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asset = this.account.asset;
    final value = NumberFormat.simpleCurrency().format(this.account.value);
    final amount = this.account.amount.toStringAsFixed(6);

    return ListTile(
      key: ValueKey(this.account.id),
      title: Text(
        this.account.name,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value),
          Text(
            "$amount ${asset.symbol}",
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
      onTap: () {
        if (this.onTap != null) {
          this.onTap(this.account);
        }
      },
    );
  }
}
