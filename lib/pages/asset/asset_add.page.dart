import "package:flutter/material.dart";

import "package:cryptarch/constants/constants.dart" show CURRENCIES;
import "package:cryptarch/models/models.dart" show Asset;
import "package:cryptarch/services/services.dart" show AssetService;
import "package:cryptarch/widgets/widgets.dart";

class AssetAddPage extends StatefulWidget {
  static String routeName = "/asset_add";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => AssetAddPage(),
    );
  }

  @override
  _AssetAddPageState createState() => _AssetAddPageState();
}

class _AssetAddPageState extends State<AssetAddPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> currency;
  List<String> exchanges = [];
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    this._formData["blockchain"] = "Ethereum";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = CURRENCIES.values.toList();
    currencies.sort((a, b) {
      return a["name"].toString().compareTo(b["name"].toString());
    });

    return Scaffold(
      appBar: FlatAppBar(
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
                    currencies: currencies,
                    initialValue: this.currency,
                    onChange: (currency) {
                      if (currency != null) {
                        final exchanges = currency["exchanges"] as List;
                        setState(() {
                          this.currency = currency;
                          this.exchanges = exchanges ?? [];
                          if (this.exchanges.isNotEmpty) {
                            this._formData["exchange"] = exchanges.first;
                          }
                        });
                      }
                    },
                  ),
                  this.exchanges.isNotEmpty
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

    String exchange = this._formData["exchange"];
    String platform = this.currency["blockchain"];
    String contractAddress = this.currency["contractAddress"];

    final existingAsset = await Asset.findOneBySymbol(symbol);
    if (existingAsset != null) {
      throw new Exception("Asset already exists");
    }

    if (exchange != null) {
      return AssetService.addAsset(symbol, exchange: exchange);
    } else {
      return AssetService.addAsset(
        symbol,
        blockchain: platform,
        contractAddress: contractAddress,
      );
    }
  }
}
