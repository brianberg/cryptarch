import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, Transaction;

class TradeListItem extends StatelessWidget {
  final Transaction trade;
  final Function onTap;

  TradeListItem({
    Key key,
    @required this.trade,
    this.onTap,
  })  : assert(trade != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatFormat = NumberFormat.simpleCurrency();

    String received;
    if (this.trade.receivedAsset.type == Asset.TYPE_FIAT) {
      received = fiatFormat.format(this.trade.receivedQuantity);
    } else {
      final quantity = this.trade.receivedQuantity.toStringAsFixed(6);
      received = "$quantity ${this.trade.receivedAsset.symbol}";
    }

    String sent;
    if (this.trade.sentAsset.type == Asset.TYPE_FIAT) {
      sent = fiatFormat.format(this.trade.sentQuantity);
    } else {
      final quantity = this.trade.sentQuantity.toStringAsFixed(6);
      sent = "$quantity ${this.trade.sentAsset.symbol}";
    }

    String title;
    Icon leadingIcon;
    switch (this.trade.type) {
      case Transaction.TYPE_BUY:
        title = "Buy";
        leadingIcon = Icon(
          Icons.add_circle_outline,
          size: 32.0,
        );
        break;
      case Transaction.TYPE_CONVERT:
        title = "Convert";
        leadingIcon = Icon(
          Icons.swap_horizontal_circle_outlined,
          size: 32.0,
        );
        break;
      case Transaction.TYPE_RECEIVE:
        title = "Receive";
        leadingIcon = Icon(
          Icons.arrow_circle_down,
          size: 32.0,
        );
        break;
      case Transaction.TYPE_SELL:
        title = "Sell";
        leadingIcon = Icon(
          Icons.remove_circle_outline,
          size: 32.0,
        );
        break;
      case Transaction.TYPE_SEND:
        title = "Send";
        leadingIcon = Icon(
          Icons.arrow_circle_up,
          size: 32.0,
        );
        break;
    }

    return ListTile(
      key: ValueKey(this.trade),
      title: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      subtitle: Text(
        dateFormat.format(this.trade.date.toLocal()),
        style: theme.textTheme.subtitle2.copyWith(
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon,
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            received,
            style: theme.textTheme.bodyText1.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            sent,
            style: theme.textTheme.subtitle2.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      onTap: () {
        if (this.onTap != null) {
          this.onTap(this.trade);
        }
      },
    );
  }
}
