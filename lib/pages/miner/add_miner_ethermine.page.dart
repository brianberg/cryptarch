import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding, Miner;
import "package:cryptarch/services/services.dart"
    show EthermineService, EtherscanService;

class AddEthermineMinerPage extends StatefulWidget {
  @override
  _AddEthermineMinerPageState createState() => _AddEthermineMinerPageState();
}

class _AddEthermineMinerPageState extends State<AddEthermineMinerPage> {
  final _formKey = GlobalKey<FormState>();

  String coin;
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
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
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Energy Consumption",
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
                              // Create miner and holding
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

    final asset = await Asset.findOneByCurrency(this.coin);

    final etherscan = EtherscanService();
    final ethermine = EthermineService();
    final balance = await etherscan.getBalance(address);
    final profitability = await ethermine.getProfitability(address);

    final holding = Holding(
      id: uuid.v1(),
      name: this.coin == "ETC" ? "Ethereum Classic" : "Ethereum",
      amount: balance,
      currency: asset.currency,
      location: "Ethermine",
    );
    await holding.save();

    final miner = Miner(
      id: uuid.v1(),
      name: "Ethermine",
      platform: "Ethermine",
      asset: asset,
      holding: holding,
      profitability: profitability,
      energy: this._formData["energy"],
    );
    await miner.save();

    return miner;
  }
}
