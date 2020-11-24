import "package:flutter/material.dart";

import "currency_picker_list.widget.dart";

class CurrencyPicker extends StatelessWidget {
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
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: SafeArea(
        child: CurrencyPickerList(
          items: this.items,
          onTap: (currency) {
            Navigator.pop(context, currency);
          },
        ),
      ),
    );
  }
}
