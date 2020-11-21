import "package:flutter/material.dart";

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

    return Padding(
      key: ValueKey(this.account.id),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Card(
        elevation: 1.0,
        child: ListTile(
          title: Text(this.account.name),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${this.account.value.toStringAsFixed(2)}",
              ),
              Text(
                "${this.account.amount.toStringAsFixed(6)} ${asset.symbol}",
                style: theme.textTheme.subtitle2,
              ),
            ],
          ),
          onTap: () {
            if (this.onTap != null) {
              this.onTap(this.account);
            }
          },
        ),
      ),
    );
  }
}
