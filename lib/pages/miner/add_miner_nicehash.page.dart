import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset, Holding, Miner;
import "package:cryptarch/services/services.dart"
    show NiceHashService, StorageService;

class AddNiceHashMinerPage extends StatefulWidget {
  @override
  _AddNiceHashMinerPageState createState() => _AddNiceHashMinerPageState();
}

class _AddNiceHashMinerPageState extends State<AddNiceHashMinerPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("NiceHash"),
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
                    child: TextFormField(
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Organization ID",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["organization_id"] = value;
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
                        labelText: "API Key",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["api_key"] = value;
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
                        labelText: "API Secret",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["api_secret"] = value;
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
                              final miner = await _saveNiceHashMiner();
                              // Securely store NiceHash credentials
                              await StorageService.putItem(
                                "nicehash",
                                this._formData,
                              );
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

  Future<Miner> _saveNiceHashMiner() async {
    final organizationId = this._formData["organization_id"];
    final apiKey = this._formData["api_key"];
    final apiSecret = this._formData["api_secret"];
    final energy = this._formData["energy"];

    final nicehash = NiceHashService(
      organizationId: organizationId,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );
    final balance = await nicehash.getAccountBalance();
    final profitability = await nicehash.getProfitability();
    final uuid = Uuid();

    final asset = await Asset.findOneByCurrency("BTC");

    final holding = Holding(
        id: uuid.v1(),
        name: "Bitcoin",
        amount: balance.available,
        currency: "BTC",
        location: "NiceHash");
    await holding.save();

    final miner = Miner(
      id: uuid.v1(),
      name: "NiceHash",
      platform: "NiceHash",
      asset: asset,
      holding: holding,
      profitability: profitability,
      energy: energy,
    );
    await miner.save();

    return miner;
  }
}
