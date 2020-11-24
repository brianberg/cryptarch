import "package:flutter/material.dart";

class CurrencyPickerListItem extends StatelessWidget {
  final Map<String, dynamic> currency;
  final Function onTap;

  CurrencyPickerListItem({
    Key key,
    @required this.currency,
    this.onTap,
  })  : assert(currency != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final symbol = this.currency["symbol"];
    final name = this.currency["name"];

    return Padding(
      key: ValueKey(this.currency),
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ListTile(
          title: Text(
            name,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          trailing: Text(
            symbol,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          onTap: this.onTap != null
              ? () {
                  this.onTap(this.currency);
                }
              : null,
        ),
      ),
    );
  }
}
