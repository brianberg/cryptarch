import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;

class AddAssetPage extends StatefulWidget {
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();

  int tab = 0;
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    this._formData["exchange"] = "Kraken";
    this._formData["tokenPlatform"] = "Ethereum";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      initialIndex: this.tab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Asset"),
          bottom: TabBar(
              tabs: [
                Tab(child: const Text("Coin")),
                Tab(child: const Text("Token")),
              ],
              onTap: (index) {
                setState(() {
                  this.tab = index;
                });
              }),
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
                          labelText: "Name",
                          filled: true,
                          fillColor: theme.cardTheme.color,
                        ),
                        onSaved: (String value) {
                          setState(() {
                            this._formData["name"] = value;
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
                          labelText: "Symbol",
                          filled: true,
                          fillColor: theme.cardTheme.color,
                        ),
                        onSaved: (String value) {
                          setState(() {
                            this._formData["symbol"] = value.toUpperCase();
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
                      child: this.tab == 0
                          ? DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Exchange",
                                filled: true,
                                fillColor: theme.cardTheme.color,
                              ),
                              dropdownColor: theme.backgroundColor,
                              value: this._formData["exchange"].toString(),
                              items: <String>[
                                "Kraken",
                                "Coinbase Pro",
                              ].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (String value) {
                                setState(() {
                                  this._formData["exchange"] = value;
                                });
                              },
                            )
                          : DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Platform",
                                filled: true,
                                fillColor: theme.cardTheme.color,
                              ),
                              dropdownColor: theme.backgroundColor,
                              value: this._formData["tokenPlatform"].toString(),
                              items: <String>[
                                "Ethereum",
                              ].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (String value) {
                                setState(() {
                                  this._formData["tokenPlatform"] = value;
                                });
                              },
                            ),
                    ),
                    this.tab == 1
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              cursorColor: theme.cursorColor,
                              decoration: InputDecoration(
                                labelText: "Contract Address",
                                filled: true,
                                fillColor: theme.cardTheme.color,
                              ),
                              onSaved: (String value) {
                                setState(() {
                                  this._formData["contractAddress"] = value;
                                });
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Required";
                                }
                                return null;
                              },
                            ),
                          )
                        : null,
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
                                final asset = await _saveAsset();
                                Navigator.pop(context, asset.symbol);
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
                  ].where((w) => w != null).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Asset> _saveAsset() async {
    final symbol = this._formData["symbol"];

    String exchange = this._formData["exchange"];
    String platform = this._formData["tokenPlatform"];
    String contractAddress = this._formData["contractAddress"];

    final existingAsset = await Asset.findOneBySymbol(symbol);
    if (existingAsset != null) {
      throw new Exception("Asset already exists");
    }

    double value = 0.0;

    if (this.tab == 0) {
      final ticker = "$symbol/USD";
      final price = await MarketsService().getPrice(ticker, exchange);
      if (price != null) {
        value = price.current;
      }
      platform = null;
      contractAddress = null;
    } else {
      final price = await MarketsService().getTokenPrice(
        platform,
        contractAddress,
        "USD",
      );
      if (price != null) {
        value = price.current;
      }
      exchange = null;
    }

    final asset = Asset(
      id: Uuid().v1(),
      name: this._formData["name"],
      symbol: this._formData["symbol"],
      value: value,
      exchange: exchange,
      tokenPlatform: platform,
      contractAddress: contractAddress,
    );
    await asset.save();

    return asset;
  }
}
