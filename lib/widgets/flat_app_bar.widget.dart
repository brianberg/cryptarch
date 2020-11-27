import "package:flutter/material.dart";

import "package:cryptarch/theme.dart";

class FlatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;
  final bool centerTitle;

  FlatAppBar({
    Key key,
    this.title,
    this.actions,
    this.centerTitle,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == AppTheme.darkTheme.brightness;

    return AppBar(
      elevation: 0.0,
      bottom: PreferredSize(
        child: Container(
          color: isDark ? null : theme.dividerColor,
          height: 1.0,
        ),
        preferredSize: Size.fromHeight(1.0),
      ),
      title: this.title,
      actions: this.actions,
      centerTitle: this.centerTitle,
    );
  }
}
