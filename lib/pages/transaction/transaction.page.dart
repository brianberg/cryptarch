import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Asset, Transaction;
import "package:cryptarch/widgets/widgets.dart";

class TradePage extends StatelessWidget {
  final Transaction trade;

  TradePage({
    Key key,
    @required this.trade,
  })  : assert(trade != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatFormat = NumberFormat.simpleCurrency();

    final sentAsset = this.trade.sentAsset;
    final receivedAsset = this.trade.receivedAsset;
    final feeAsset = this.trade.feeAsset;
    final type = this.trade.type;

    String sent;
    String received;
    String price;
    String fee;
    String total;

    switch (type) {
      case Transaction.TYPE_BUY:
        final receivedQuantity = this.trade.receivedQuantity.toStringAsFixed(6);
        sent = fiatFormat.format(this.trade.sentQuantity);
        received = "$receivedQuantity ${receivedAsset.symbol}";
        price = fiatFormat.format(this.trade.rate);
        fee = fiatFormat.format(this.trade.feeQuantity);
        total = fiatFormat.format(this.trade.total);
        break;
      case Transaction.TYPE_SELL:
        final sentQuantity = this.trade.sentQuantity.toStringAsFixed(6);
        sent = "$sentQuantity ${sentAsset.symbol}";
        received = fiatFormat.format(this.trade.receivedQuantity);
        price = "${this.trade.rate} ${sentAsset.symbol}";
        fee = fiatFormat.format(this.trade.feeQuantity);
        total = fiatFormat.format(this.trade.total);
        break;
      case Transaction.TYPE_CONVERT:
        final sentQuantity = this.trade.sentQuantity.toStringAsFixed(6);
        final receivedQuantity = this.trade.receivedQuantity.toStringAsFixed(6);
        final feeQuantity = this.trade.feeQuantity.toStringAsFixed(6);
        sent = "$sentQuantity ${sentAsset.symbol}";
        received = "$receivedQuantity ${receivedAsset.symbol}";
        price = "${this.trade.rate} ${receivedAsset.symbol}";
        fee =
            feeAsset != null ? "$feeQuantity ${feeAsset.symbol}" : feeQuantity;
        total = "${this.trade.total} ${receivedAsset.symbol}";
        break;
    }

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("${receivedAsset.symbol} - ${sentAsset.symbol}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: const Text("Type"),
                trailing: Text(type[0].toUpperCase() + type.substring(1)),
              ),
              ListTile(
                title: const Text("Date"),
                trailing: Text(dateFormat.format(this.trade.date)),
              ),
              ListTile(
                title: const Text("Sent"),
                trailing: Text(sent),
              ),
              ListTile(
                title: const Text("Received"),
                trailing: Text(received),
              ),
              ListTile(
                title: const Text("Price"),
                trailing: Text(price),
              ),
              ListTile(
                title: const Text("Fee"),
                trailing: Text(fee),
              ),
              Divider(),
              ListTile(
                title: const Text("Total"),
                trailing: Text(total),
              ),
              ListTile(
                title: const Text("Value"),
                trailing: Text(fiatFormat.format(this.trade.currentValue)),
              ),
              ListTile(
                title: const Text("Return"),
                trailing: CurrencyChange(
                  value: this.trade.returnValue,
                  style: theme.textTheme.subtitle2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
