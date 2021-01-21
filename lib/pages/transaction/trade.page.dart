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
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatFormat = NumberFormat.simpleCurrency();

    final sentAsset = this.trade.sentAsset;
    final receivedAsset = this.trade.receivedAsset;

    final type =
        this.trade.type[0].toUpperCase() + this.trade.type.substring(1);

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

    String fee;
    if (this.trade.feeAsset.type == Asset.TYPE_FIAT) {
      fee = fiatFormat.format(this.trade.feeQuantity);
    } else {
      final quantity = this.trade.feeQuantity.toStringAsFixed(6);
      fee = "$quantity ${this.trade.feeAsset.symbol}";
    }

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("${receivedAsset.symbol} / ${sentAsset.symbol}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: const Text("Type"),
                trailing: Text(type),
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
                title: const Text("Fee"),
                trailing: Text(fee),
              ),
              ListTile(
                title: const Text("Total"),
                trailing: Text(fiatFormat.format(this.trade.total)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
