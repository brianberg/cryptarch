import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class AccountList extends StatelessWidget {
  final Function onTap;
  final List<Account> items;

  AccountList({
    Key key,
    this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No accounts")),
      );
    }

    return Column(
      children: this.items.map((account) {
        return AccountListItem(
          account: account,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
