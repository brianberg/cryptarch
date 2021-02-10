import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/theme.dart";

enum AppTab { home, portfolio, trades, mining }

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
  final _navigatorKeys = {
    AppTab.home: GlobalKey<NavigatorState>(),
    AppTab.portfolio: GlobalKey<NavigatorState>(),
    AppTab.trades: GlobalKey<NavigatorState>(),
    AppTab.mining: GlobalKey<NavigatorState>(),
  };

  AppTab _tab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        final navigatorKey = this._navigatorKeys[this._tab];
        final popHandled = await navigatorKey.currentState.maybePop();
        return !popHandled;
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: this._tab.index,
            children: <Widget>[
              Navigator(
                key: this._navigatorKeys[AppTab.home],
                onGenerateRoute: (route) {
                  return MaterialPageRoute(
                    settings: route,
                    builder: (context) => HomePage(),
                  );
                },
              ),
              Navigator(
                key: this._navigatorKeys[AppTab.trades],
                onGenerateRoute: (route) {
                  return MaterialPageRoute(
                    settings: route,
                    builder: (context) => TransactionsPage(),
                  );
                },
              ),
              Navigator(
                key: this._navigatorKeys[AppTab.mining],
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
          currentIndex: this._tab.index,
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
      ),
    );
  }

  void _onSelectTab(int index) {
    if (this._tab.index == index) {
      this
          ._navigatorKeys[this._tab]
          .currentState
          .popUntil((route) => route.isFirst);
    } else {
      if (mounted) {
        setState(() {
          this._tab = AppTab.values[index];
        });
      }
    }
  }
}
