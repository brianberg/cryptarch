import "dart:ui";

import "package:flutter/material.dart";

import "package:intl/intl.dart";

import "package:cryptarch/models/models.dart" show Transaction;
import "package:cryptarch/widgets/widgets.dart";

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailPage({
    Key key,
    @required this.transaction,
  })  : assert(transaction != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("MM/dd/yyyy");
    final fiatFormat = NumberFormat.simpleCurrency();

    final sentAsset = this.transaction.sentAsset;
    final receivedAsset = this.transaction.receivedAsset;
    final feeAsset = this.transaction.feeAsset;
    final type = this.transaction.type;

    String sent;
    String received;
    String price;
    String fee;
    String total;

    switch (type) {
      case Transaction.TYPE_BUY:
        final receivedQuantity =
            this.transaction.receivedQuantity.toStringAsFixed(6);
        sent = fiatFormat.format(this.transaction.sentQuantity);
        received = "$receivedQuantity ${receivedAsset.symbol}";
        price = fiatFormat.format(this.transaction.rate);
        fee = fiatFormat.format(this.transaction.feeQuantity);
        total = fiatFormat.format(this.transaction.total);
        break;
      case Transaction.TYPE_SELL:
        final sentQuantity = this.transaction.sentQuantity.toStringAsFixed(6);
        final rate = this.transaction.rate.toStringAsFixed(6);
        sent = "$sentQuantity ${sentAsset.symbol}";
        received = fiatFormat.format(this.transaction.receivedQuantity);
        price = "$rate ${sentAsset.symbol}";
        fee = fiatFormat.format(this.transaction.feeQuantity);
        total = fiatFormat.format(this.transaction.total);
        break;
      case Transaction.TYPE_CONVERT:
        final sentQuantity = this.transaction.sentQuantity.toStringAsFixed(6);
        final receivedQuantity =
            this.transaction.receivedQuantity.toStringAsFixed(6);
        final rate = this.transaction.rate.toStringAsFixed(6);
        final feeQuantity = this.transaction.feeQuantity.toStringAsFixed(6);
        final totalQuantity = this.transaction.total.toStringAsFixed(6);
        sent = "$sentQuantity ${sentAsset.symbol}";
        received = "$receivedQuantity ${receivedAsset.symbol}";
        price = "$rate ${receivedAsset.symbol}";
        fee =
            feeAsset != null ? "$feeQuantity ${feeAsset.symbol}" : feeQuantity;
        total = "$totalQuantity ${receivedAsset.symbol}";
        break;
    }

    return Scaffold(
      appBar: FlatAppBar(
        title: Text("${receivedAsset.symbol} - ${sentAsset.symbol}"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              try {
                await this.transaction.delete();
                Navigator.pop(context);
              } catch (err) {
                // final snackBar = SnackBar(
                //   content: Text(err.message),
                // );
                // Scaffold.of(context).showSnackBar(snackBar);
                print(err);
              }
            },
          )
        ],
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
                trailing: Text(dateFormat.format(this.transaction.date)),
              ),
              ListTile(
                title: const Text("Sent"),
                trailing: Text(
                  sent,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Received"),
                trailing: Text(
                  received,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Price"),
                trailing: Text(
                  price,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Fee"),
                trailing: Text(
                  fee,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Divider(),
              ListTile(
                title: const Text("Total"),
                trailing: Text(
                  total,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Value"),
                trailing: Text(
                  fiatFormat.format(this.transaction.currentValue),
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ListTile(
                title: const Text("Return"),
                trailing: CurrencyChange(
                  value: this.transaction.returnValue,
                  style: theme.textTheme.bodyText2.copyWith(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
