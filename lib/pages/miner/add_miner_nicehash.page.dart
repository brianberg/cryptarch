import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart"
    show Asset, Account, Miner, Payout;
import "package:cryptarch/services/services.dart"
    show AssetService, NiceHashService, StorageService;
import "package:cryptarch/widgets/widgets.dart";

class AddNiceHashMinerPage extends StatefulWidget {
  @override
  _AddNiceHashMinerPageState createState() => _AddNiceHashMinerPageState();
}

class _AddNiceHashMinerPageState extends State<AddNiceHashMinerPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
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
                              final miner = await _saveNiceHashMiner();
                              if (miner != null) {
                                Navigator.pop(context, miner.id);
                              }
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
    // Securely store NiceHash credentials
    final credentials = {
      "organization_id": this._formData["organization_id"],
      "api_key": this._formData["api_key"],
      "api_secret": this._formData["api_secret"],
    };
    await StorageService.putItem(
      "nicehash",
      credentials,
    );

    final nicehash = NiceHashService();
    final balance = await nicehash.getAccountBalance();
    final profitability = await nicehash.getProfitability();
    final uuid = Uuid();

    Asset asset = await Asset.findOneBySymbol("BTC");

    // Add asset if it doesn't exist
    if (asset == null) {
      asset = await AssetService.addAsset("BTC");
    }

    final account = Account(
      id: uuid.v1(),
      name: "NiceHash",
      asset: asset,
      amount: balance.available,
    );
    await account.save();

    final miner = Miner(
      id: uuid.v1(),
      name: "NiceHash",
      platform: "NiceHash",
      asset: asset,
      account: account,
      profitability: profitability,
      energy: this._formData["energy"],
      active: true,
      unpaidAmount: balance.pending,
    );
    await miner.save();

    try {
      await nicehash.getPayoutHistory(miner);
      return miner;
    } catch (err) {
      await Payout.deleteMany({"minerId": miner.id});
      await miner.delete();
      await account.delete();
      return null;
    }
  }
}
