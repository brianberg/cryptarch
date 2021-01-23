import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/widgets/widgets.dart";

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
    final dateFormat = DateFormat("MMM dd, yyyy");
    final fiatFormat = NumberFormat.simpleCurrency();

    final date = dateFormat.format(this.trade.date.toLocal());

    String title;
    Icon leadingIcon;
    String quantity;
    String price;

    switch (this.trade.type) {
      case Transaction.TYPE_BUY:
        title = "Buy";
        leadingIcon = Icon(
          Icons.add_circle_outline,
          size: 32.0,
        );
        final receivedQuantity = this.trade.receivedQuantity.toStringAsFixed(6);
        quantity = "$receivedQuantity ${this.trade.receivedAsset.symbol}";
        price = fiatFormat.format(this.trade.rate);
        break;
      case Transaction.TYPE_CONVERT:
        title = "Convert";
        leadingIcon = Icon(
          Icons.swap_horizontal_circle_outlined,
          size: 32.0,
        );
        final sentQuantity = this.trade.sentQuantity.toStringAsFixed(6);
        final rate = this.trade.rate.toStringAsFixed(6);
        quantity = "$sentQuantity ${this.trade.sentAsset.symbol}";
        price = "$rate ${this.trade.receivedAsset.symbol}";
        break;
      case Transaction.TYPE_SELL:
        title = "Sell";
        leadingIcon = Icon(
          Icons.remove_circle_outline,
          size: 32.0,
        );
        final sentQuantity = this.trade.sentQuantity.toStringAsFixed(6);
        quantity = "$sentQuantity ${this.trade.sentAsset.symbol}";
        price = fiatFormat.format(this.trade.rate);
        break;
      // case Transaction.TYPE_SEND:
      //   title = "Send";
      //   leadingIcon = Icon(
      //     Icons.arrow_circle_up,
      //     size: 32.0,
      //   );
      //   break;
      // case Transaction.TYPE_RECEIVE:
      //   title = "Receive";
      //   leadingIcon = Icon(
      //     Icons.arrow_circle_down,
      //     size: 32.0,
      //   );
      //   break;
    }

    return ListTile(
      key: ValueKey(this.trade),
      isThreeLine: true,
      title: Text(
        title,
        style: theme.textTheme.bodyText1,
      ),
      subtitle: Text(
        "${this.trade.receivedAsset.symbol}-${this.trade.sentAsset.symbol}\n$date",
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
            quantity,
            style: theme.textTheme.bodyText1.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            price,
            style: theme.textTheme.subtitle2.copyWith(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          CurrencyChange(
            value: this.trade.returnValue,
            style: theme.textTheme.subtitle2,
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
