import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";

import "asset_picker.widget.dart";

class AssetField extends StatelessWidget {
  final String label;
  final List<Asset> assets;
  final Function onChange;
  final Asset initialValue;

  AssetField({
    Key key,
    @required this.label,
    this.assets,
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
                          ? this.initialValue.name
                          : "None"),
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
              builder: (context) => AssetPicker(
                title: this.label,
                assets: this.assets,
                selected: this.initialValue,
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
