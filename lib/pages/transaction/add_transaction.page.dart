import "package:flutter/material.dart";

import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset, Transaction;
import "package:cryptarch/widgets/widgets.dart";

class AddTransactionPage extends StatefulWidget {
  final String type;

  AddTransactionPage({
    Key key,
    @required this.type,
  })  : assert(type != null),
        super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateInputController = TextEditingController();
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");

  Map<String, dynamic> _formData = {
    "date": DateTime.now(),
  };

  Asset receivedAsset;
  Asset sentAsset;
  Asset feeAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedDate = this._formData["date"];
    this._dateInputController.text = this.dateFormat.format(selectedDate);

    Text title;
    switch (this.widget.type) {
      case Transaction.TYPE_BUY:
        title = const Text("Add Buy");
        break;
      case Transaction.TYPE_SELL:
        title = const Text("Add Sell");
        break;
      case Transaction.TYPE_CONVERT:
        title = const Text("Add Conversion");
        break;
      default:
        title = const Text("Add Transaction");
    }

    return Scaffold(
      appBar: FlatAppBar(
        title: title,
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
                  this.widget.type == Transaction.TYPE_BUY
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AssetField(
                            label: "Bought",
                            initialValue: this.receivedAsset,
                            onChange: (Asset asset) {
                              setState(() {
                                this.receivedAsset = asset;
                              });
                            },
                          ),
                        )
                      : null,
                  this.widget.type == Transaction.TYPE_SELL
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AssetField(
                            label: "Sold",
                            initialValue: this.sentAsset,
                            onChange: (Asset asset) {
                              setState(() {
                                this.sentAsset = asset;
                              });
                            },
                          ),
                        )
                      : null,
                  this.widget.type == Transaction.TYPE_CONVERT
                      ? Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: AssetField(
                                label: "From",
                                initialValue: this.sentAsset,
                                onChange: (Asset asset) {
                                  setState(() {
                                    this.sentAsset = asset;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: AssetField(
                                label: "To",
                                initialValue: this.receivedAsset,
                                onChange: (Asset asset) {
                                  setState(() {
                                    this.receivedAsset = asset;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : null,
                  this.widget.type == Transaction.TYPE_CONVERT
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Sent",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: this.sentAsset != null
                                      ? Text(this.sentAsset.symbol)
                                      : null,
                                ),
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["sent"] =
                                        double.parse(value);
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Received",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: this.receivedAsset != null
                                      ? Text(this.receivedAsset.symbol)
                                      : null,
                                ),
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["received"] =
                                        double.parse(value);
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Fee",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: this.receivedAsset != null
                                      ? Text(this.receivedAsset.symbol)
                                      : null,
                                ),
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["fee"] = value.isNotEmpty
                                        ? double.parse(value)
                                        : 0.0;
                                  });
                                },
                                validator: (value) {
                                  if (value.isNotEmpty) {
                                    if (double.tryParse(value) == null) {
                                      return "Invalid";
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: this.receivedAsset != null
                                      ? Text(this.receivedAsset.symbol)
                                      : null,
                                ),
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["amount"] =
                                        double.parse(value);
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Price",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: const Text("USD"),
                                ),
                                // initialValue: this._formData["rate"],
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["rate"] =
                                        double.parse(value);
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: theme.cursorColor,
                                decoration: InputDecoration(
                                  labelText: "Fee",
                                  filled: true,
                                  fillColor: theme.cardTheme.color,
                                  suffix: const Text("USD"),
                                ),
                                initialValue: "0",
                                onSaved: (String value) {
                                  setState(() {
                                    this._formData["fee"] = double.parse(value);
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
                          ],
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: this._dateInputController,
                            decoration: InputDecoration(
                              labelText: "Date",
                              labelStyle: TextStyle(
                                color: theme.textTheme.bodyText1.color,
                              ),
                              filled: true,
                              enabled: false,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final selected = await this._selectDate(
                              context,
                              selectedDate,
                            );
                            if (selected != null) {
                              setState(() {
                                this._formData["date"] = selected;
                              });
                            }
                          },
                        ),
                      ],
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
                              await _saveTransaction();
                              Navigator.pop(context, 1);
                            } catch (err) {
                              // final snackBar = SnackBar(
                              //   content: Text(err.message),
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

  Future<DateTime> _selectDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != initialDate) {
      return picked;
    }

    return null;
  }

  Future<void> _saveTransaction() async {
    final selectedDate = this._formData["date"] as DateTime;

    double sentQuantity;
    double receivedQuantity;
    double feeQuantity = this._formData["fee"] as double;

    switch (this.widget.type) {
      case Transaction.TYPE_BUY:
        final fiat = await Asset.findOneBySymbol("USD");
        final rate = this._formData["rate"] as double;
        final amount = this._formData["amount"] as double;
        this.sentAsset = fiat;
        this.feeAsset = fiat;
        receivedQuantity = amount;
        sentQuantity = amount * rate;
        break;
      case Transaction.TYPE_SELL:
        final fiat = await Asset.findOneBySymbol("USD");
        final rate = this._formData["rate"] as double;
        final amount = this._formData["amount"] as double;
        this.receivedAsset = fiat;
        this.feeAsset = fiat;
        sentQuantity = amount;
        receivedQuantity = amount * rate;
        break;
      case Transaction.TYPE_CONVERT:
        final sent = this._formData["sent"] as double;
        final received = this._formData["received"] as double;
        this.feeAsset = this.receivedAsset;
        sentQuantity = sent;
        receivedQuantity = received;
        break;
    }

    final transaction = Transaction(
      id: Uuid().v1(),
      type: this.widget.type,
      date: selectedDate.toUtc(),
      sentAsset: this.sentAsset,
      sentQuantity: sentQuantity,
      receivedAsset: this.receivedAsset,
      receivedQuantity: receivedQuantity,
      feeAsset: this.feeAsset,
      feeQuantity: feeQuantity,
    );

    await transaction.save();
  }
}
