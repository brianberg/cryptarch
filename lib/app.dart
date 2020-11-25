import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "package:cryptarch/pages/pages.dart";
import "package:cryptarch/services/services.dart" show SettingsService;
import 'package:cryptarch/theme.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsService>(
      future: this._loadSettings(),
      builder: (BuildContext context, AsyncSnapshot<SettingsService> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }
        return ChangeNotifierProvider(
          create: (context) => snapshot.data,
          child: MaterialApp(
            title: "Cryptarch",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: TabContainer(),
            routes: <String, WidgetBuilder>{
              PortfolioPage.routeName: (context) => PortfolioPage(),
              PricesPage.routeName: (context) => PricesPage(),
              MiningPage.routeName: (context) => MiningPage(),
              SettingsPage.routeName: (context) => SettingsPage(),
            },
          ),
        );
      },
    );
  }

  Future<SettingsService> _loadSettings() async {
    final settingsService = SettingsService();
    await settingsService.getSettings();
    return settingsService;
  }
}

class TabContainer extends StatefulWidget {
  @override
  _TabContainerState createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final theme = Theme.of(context);
        final settings = settingsService.settings;

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
              settings.showMining
                  ? BottomNavigationBarItem(
                      label: "Mining",
                      icon: Icon(Icons.engineering),
                    )
                  : null,
            ].where((w) => w != null).toList(),
            onTap: (index) {
              setState(() {
                this._tabIndex = index;
              });
            },
          ),
        );
      },
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
        return Consumer<SettingsService>(
          builder: (context, settingsService, child) {
            return HomePage(settings: settingsService.settings);
          },
        );
    }
  }
}
