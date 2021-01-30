import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show SettingsService;
import "package:cryptarch/theme.dart";

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cryptarch",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: AppView(),
      routes: <String, WidgetBuilder>{
        PortfolioPage.routeName: (context) => PortfolioPage(),
        PricesPage.routeName: (context) => PricesPage(),
        MiningPage.routeName: (context) => MiningPage(),
        SettingsPage.routeName: (context) => SettingsPage(),
      },
    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _homeTab = GlobalKey<NavigatorState>();
  final _portfolioTab = GlobalKey<NavigatorState>();
  final _tradesTab = GlobalKey<NavigatorState>();
  final _miningTab = GlobalKey<NavigatorState>();

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: this._tabIndex,
          children: <Widget>[
            Navigator(
              key: this._homeTab,
              onGenerateRoute: (route) {
                return MaterialPageRoute(
                  settings: route,
                  builder: (context) => HomePage(),
                );
              },
            ),
            Navigator(
              key: this._portfolioTab,
              onGenerateRoute: (route) {
                return MaterialPageRoute(
                  settings: route,
                  builder: (context) => PortfolioPage(),
                );
              },
            ),
            Navigator(
              key: this._tradesTab,
              onGenerateRoute: (route) {
                return MaterialPageRoute(
                  settings: route,
                  builder: (context) => TransactionsPage(),
                );
              },
            ),
            Navigator(
              key: this._miningTab,
              onGenerateRoute: (route) {
                return MaterialPageRoute(
                  settings: route,
                  builder: (context) => MiningPage(),
                );
              },
            ),
          ],
        ),
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
            label: "Trades",
            icon: Icon(Icons.swap_horiz),
          ),
          BottomNavigationBarItem(
            label: "Mining",
            icon: Icon(Icons.engineering),
          )
        ].where((w) => w != null).toList(),
        onTap: this._onSelectTab,
      ),
    );
  }

  void _onSelectTab(int index) {
    if (this._tabIndex == index) {
      switch (index) {
        case 0:
          this._homeTab.currentState.popUntil((route) => route.isFirst);
          break;
        case 1:
          this._portfolioTab.currentState.popUntil((route) => route.isFirst);
          break;
        // case 2:
        //   this._tradesTab.currentState.popUntil((route) => route.isFirst);
        //   break;
        case 2:
          this._miningTab.currentState.popUntil((route) => route.isFirst);
          break;
        default:
      }
    } else {
      if (mounted) {
        setState(() {
          this._tabIndex = index;
        });
      }
    }
  }
}
