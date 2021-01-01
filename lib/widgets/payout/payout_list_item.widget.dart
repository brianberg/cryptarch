import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Payout;
import 'package:intl/intl.dart';

class PayoutListItem extends StatelessWidget {
  final Payout payout;
  final Function onTap;

  PayoutListItem({
    Key key,
    @required this.payout,
    this.onTap,
  })  : assert(payout != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatValue = NumberFormat.simpleCurrency().format(this.payout.value);

    return ListTile(
      key: ValueKey(this.payout.id),
      title: Text(
        "Mining payment",
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      subtitle: Text(
        dateFormat.format(this.payout.date),
        style: theme.textTheme.subtitle2,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(this.payout.amount.toStringAsFixed(8)),
          Text(
            fiatValue,
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
