import "package:flutter/material.dart";

import "currency_picker_list_item.widget.dart";

class CurrencyPickerList extends StatelessWidget {
  final Function onTap;
  final List<Map<String, dynamic>> items;

  CurrencyPickerList({
    Key key,
    @required this.items,
    this.onTap,
  })  : assert(items != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: this.items.length,
      itemBuilder: (BuildContext context, int index) {
        final currency = this.items[index];
        return CurrencyPickerListItem(
          currency: currency,
          onTap: this.onTap,
        );
      },
    );
  }
}
