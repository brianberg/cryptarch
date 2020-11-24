import "package:flutter/material.dart";

import "currency_picker.widget.dart";

class CurrencyField extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> currencies;
  final Function onChange;
  final Map<String, dynamic> initialValue;

  CurrencyField({
    Key key,
    @required this.label,
    this.currencies,
    this.onChange,
    this.initialValue,
  })  : assert(label != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.label,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(this.initialValue != null
                          ? this.initialValue["symbol"]
                          : "Default"),
                    ),
                  ],
                ),
              ),
              this.initialValue != null
                  ? SizedBox(
                      height: 42.0,
                      child: IconButton(
                        color: Theme.of(context).iconTheme.color,
                        icon: Icon(Icons.close),
                        onPressed: () {
                          this._onChange(null);
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        onTap: () async {
          var selected = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurrencyPicker(
                title: this.label,
                items: this.currencies,
              ),
            ),
          );
          this._onChange(selected);
        },
      ),
    );
  }

  String _onChange(dynamic value) {
    if (this.onChange != null) {
      return this.onChange(value);
    }
    return null;
  }
}
