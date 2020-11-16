import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/ui/theme.dart";

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cryptarch",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: AppContainer(),
    );
  }
}

class AppContainer extends StatefulWidget {
  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: this._getTabBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: this._tabIndex,
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: theme.colorScheme.onPrimary,
        unselectedItemColor: theme.colorScheme.onPrimary.withOpacity(.60),
        selectedLabelStyle: theme.textTheme.caption,
        unselectedLabelStyle: theme.textTheme.caption,
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home_filled),
          ),
          BottomNavigationBarItem(
            label: "Portfolio",
            icon: Icon(Icons.pie_chart),
          ),
          BottomNavigationBarItem(
            label: "Prices",
            icon: Icon(Icons.bar_chart),
          ),
          BottomNavigationBarItem(
            label: "Mining",
            icon: Icon(Icons.engineering),
          ),
        ],
        onTap: (index) {
          setState(() {
            this._tabIndex = index;
          });
        },
      ),
    );
  }

  Widget _getTabBody() {
    switch (this._tabIndex) {
      case 1:
        return PortfolioPage();
      case 2:
        return PricesPage();
      case 3:
        return MiningPage();
      default:
        return HomePage();
    }
  }
}
