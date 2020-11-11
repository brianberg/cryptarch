import 'package:cryptarch/services/markets.service.dart';
import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset;

class AddAssetPage extends StatefulWidget {
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    this._formData["exchange"] = "Kraken";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Asset"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        labelText: "Currency",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        // TODO: find asset for currency
                        setState(() {
                          this._formData["currency"] = value;
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
                    child: DropdownButtonFormField(
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
                        }),
                  ),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        child: Text("Add"),
                        color: theme.buttonColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            _formKey.currentState.save();
                            try {
                              final asset = await _saveAsset();
                              Navigator.pop(context, asset.currency);
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

  Future<Asset> _saveAsset() async {
    final currency = this._formData["currency"];
    final exchange = this._formData["exchange"];
    final existingAsset = await Asset.findOneByCurrency(currency);
    if (existingAsset != null) {
      throw new Exception("Asset already exists");
    } else {
      final ticker = "$currency/USD";
      final value = await MarketsService().getPrice(ticker, exchange);
      if (value != null) {
        this._formData["id"] = Uuid().v1();
        this._formData["value"] = value;
        final asset = await Asset.deserialize(this._formData);
        await asset.save();
        return asset;
      } else {
        throw new Exception("Market price not found, try another exchange");
      }
    }
  }
}
