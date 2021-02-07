import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/widgets/widgets.dart";

class TransactionList extends StatelessWidget {
  final Function onTap;
  final List<Transaction> items;

  TransactionList({
    Key key,
    this.items,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items == null || this.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("No transactions")),
      );
    }

    return Column(
      children: this.items.map((transaction) {
        return TransactionListItem(
          transaction: transaction,
          onTap: this.onTap,
        );
      }).toList(),
    );
  }
}
