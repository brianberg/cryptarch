import "package:flutter/material.dart";

class PortfolioPage extends StatelessWidget {
  static const routeName = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio"),
      ),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
