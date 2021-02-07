import "package:flutter/material.dart";

import "package:flutter_svg/flutter_svg.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;

class AssetIcon extends StatelessWidget {
  final Asset asset;

  AssetIcon({
    Key key,
    @required this.asset,
  })  : assert(asset != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currency = CURRENCIES[this.asset.symbol];
    final iconPath = currency["icon"].toString();

    if (iconPath.endsWith(".svg")) {
      return SizedBox(
        width: 36.0,
        height: 36.0,
        child: SvgPicture.asset(
          iconPath,
          semanticsLabel: this.asset.name,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          width: 1,
          color: theme.dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: 32.0,
          height: 32.0,
          child: Image(
            image: AssetImage(iconPath),
          ),
        ),
      ),
    );
  }
}
