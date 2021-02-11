import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart"
    show Asset, Account, Miner, Payout;
import "package:cryptarch/services/services.dart"
    show AssetService, EthermineService, EtherscanService;
import "package:cryptarch/widgets/widgets.dart";

class MinerAddEtherminePage extends StatefulWidget {
  static String routeName = "/miner_add_ethermine";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => MinerAddEtherminePage(),
    );
  }

  @override
  _MinerAddEtherminePageState createState() => _MinerAddEtherminePageState();
}

class _MinerAddEtherminePageState extends State<MinerAddEtherminePage> {
  final _formKey = GlobalKey<FormState>();

  String coin;
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Ethermine"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Coin",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      dropdownColor: theme.backgroundColor,
                      value: this.coin,
                      items: <String>[
                        "ETH",
                        "ETC",
                      ].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          this.coin = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Wallet Address",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["address"] = value;
                        });
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Required";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Daily Energy Usage",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: const Text("kWh"),
                      ),
                      initialValue: "0",
                      onSaved: (String value) {
                        setState(() {
                          this._formData["energy"] = double.parse(value);
                        });
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Required";
                        } else if (double.tryParse(value) == null) {
                          return "Invalid";
                        }
                        return null;
                      },
                    ),
                  ),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        child: Text("Add", style: theme.textTheme.button),
                        color: theme.buttonColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            _formKey.currentState.save();
                            try {
                              // Create miner and account
                              final miner = await _saveEthermineMiner();
                              Navigator.pop(context, miner.id);
                            } catch (err) {
                              // final snackBar = SnackBar(
                              //   content: Text(err),
                              // );
                              // Scaffold.of(context).showSnackBar(snackBar);
                              print(err);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Miner> _saveEthermineMiner() async {
    final uuid = Uuid();
    final address = this._formData["address"];

    Asset asset = await Asset.findOneBySymbol(this.coin);

    // Add asset if it doesn"t exist
    if (asset == null) {
      asset = await AssetService.addAsset(this.coin);
    }

    final etherscan = EtherscanService();
    final ethermine = EthermineService();
    final balance = await etherscan.getBalance(address);
    final profitability = await ethermine.getProfitability(address);
    final unpaid = await ethermine.getUnpaid(address);

    final account = Account(
      id: uuid.v1(),
      name: "Ethermine",
      asset: asset,
      amount: balance,
      address: address,
    );
    await account.save();

    final miner = Miner(
      id: uuid.v1(),
      name: "Ethermine",
      platform: "Ethermine",
      asset: asset,
      account: account,
      profitability: profitability,
      energy: this._formData["energy"],
      active: true,
      unpaidAmount: unpaid,
    );
    await miner.save();

    try {
      await ethermine.getPayoutHistory(miner);
      return miner;
    } catch (err) {
      await Payout.deleteMany({"minerId": miner.id});
      await miner.delete();
      await account.delete();
      return null;
    }
  }
}
