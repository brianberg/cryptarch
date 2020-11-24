import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show MarketsService;
import "package:cryptarch/ui/widgets.dart";

class AddAssetPage extends StatefulWidget {
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> currency;
  List<String> exchanges = [];
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    this._formData["tokenPlatform"] = "Ethereum";
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
                children: <Widget>[
                  CurrencyField(
                    label: "Currency",
                    currencies: CURRENCIES.values.toList(),
                    initialValue: this.currency,
                    onChange: (currency) {
                      if (currency != null) {
                        final exchanges = currency["exchanges"] as List;
                        setState(() {
                          this.currency = currency;
                          this.exchanges = exchanges;
                          if (exchanges.length > 0) {
                            this._formData["exchange"] = exchanges.first;
                          }
                        });
                      }
                    },
                  ),
                  this.exchanges.length > 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: "Exchange",
                              filled: true,
                              fillColor: theme.cardTheme.color,
                            ),
                            dropdownColor: theme.backgroundColor,
                            value: this._formData["exchange"].toString(),
                            items: this.exchanges.map((String value) {
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
    );
  }

  Future<Asset> _saveAsset() async {
    final symbol = this.currency["symbol"];
    final name = this.currency["name"];

    String exchange = this._formData["exchange"];
    String platform = this.currency["tokenPlatform"];
    String contractAddress = this.currency["contractAddress"];

    final existingAsset = await Asset.findOneBySymbol(symbol);
    if (existingAsset != null) {
      throw new Exception("Asset already exists");
    }

    double value = 0.0;

    if (exchange != null) {
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
      name: name,
      symbol: symbol,
      value: value,
      exchange: exchange,
      tokenPlatform: platform,
      contractAddress: contractAddress,
    );
    await asset.save();

    return asset;
  }
}
