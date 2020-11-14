import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";

class AssetPickerListItem extends StatelessWidget {
  final Asset asset;
  final bool selected;
  final Function onTap;

  AssetPickerListItem({
    Key key,
    @required this.asset,
    @required this.selected,
    this.onTap,
  })  : assert(asset != null),
        assert(selected != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(this.asset.id),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(
            color: this.selected
                ? Theme.of(context).accentColor
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ListTile(
          title: Text(
            this.asset.name,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          trailing: Text(
            this.asset.currency,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          onTap: this.onTap != null
              ? () {
                  this.onTap(this.asset);
                }
              : null,
        ),
      ),
    );
  }
}
