import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart";
import "package:cryptarch/widgets/widgets.dart";

class AccountList extends StatelessWidget {
  final Function onTap;
  final List<Account> items;
  final Map<String, dynamic> filters;

  AccountList({
    Key key,
    this.items,
    this.onTap,
    this.filters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.items != null) {
      return _buildList(this.items);
    }
    return FutureBuilder<List<Account>>(
      future: Account.find(filters: this.filters),
      builder: (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return LoadingIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            List<Account> accounts = snapshot.data;
            return _buildList(accounts);
        }
        return Container(child: const Text("Unable to get accounts"));
      },
    );
  }

  Widget _buildList(List<Account> accounts) {
    if (accounts.length == 0) {
      return Center(child: Text("Wow, so empty"));
    }

    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (BuildContext context, int index) {
        return AccountListItem(
          account: accounts[index],
          onTap: this.onTap,
        );
      },
    );
  }
}
