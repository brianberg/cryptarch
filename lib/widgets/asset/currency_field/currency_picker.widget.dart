import "package:flutter/material.dart";

import "package:cryptarch/widgets/widgets.dart";

import "package:cryptarch/widgets/widgets.dart" show CurrencyListItem;

class CurrencyPicker extends StatelessWidget {
  static Route route(String title, List<Map<String, dynamic>> items) {
    return MaterialPageRoute<void>(
      builder: (_) => CurrencyPicker(
        title: title,
        items: items,
      ),
    );
  }

  final String title;
  final List<Map<String, dynamic>> items;

  CurrencyPicker({
    Key key,
    @required this.title,
    @required this.items,
  })  : assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlatAppBar(
        title: Text(this.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: this.items.length,
            itemBuilder: (BuildContext context, int index) {
              final currency = this.items[index];
              return CurrencyListItem(
                currency: currency,
                onTap: (currency) {
                  Navigator.pop(context, currency);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
