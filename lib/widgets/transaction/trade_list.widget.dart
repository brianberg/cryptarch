import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/widgets/widgets.dart";

class TradeList extends StatelessWidget {
  final Function onTap;
  final List<Transaction> trades;

  TradeList({
    Key key,
    @required this.trades,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.trades.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: this.trades.length,
      itemBuilder: (BuildContext context, int index) {
        return TradeListItem(
          trade: this.trades[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
