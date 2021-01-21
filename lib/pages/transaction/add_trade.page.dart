import "package:flutter/material.dart";

import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Asset, Transaction;
import "package:cryptarch/widgets/widgets.dart";

class AddTradePage extends StatefulWidget {
  @override
  _AddTradePageState createState() => _AddTradePageState();
}

class _AddTradePageState extends State<AddTradePage> {
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

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Add Trade"),
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
                    child: AssetField(
                      label: "Received",
                      initialValue: this.receivedAsset,
                      onChange: (Asset asset) {
                        setState(() {
                          this.receivedAsset = asset;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AssetField(
                      label: "Sent",
                      initialValue: this.sentAsset,
                      onChange: (Asset asset) {
                        setState(() {
                          this.sentAsset = asset;
                          this.feeAsset = asset;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["amount"] = double.parse(value);
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Rate",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      // initialValue: this._formData["rate"],
                      onSaved: (String value) {
                        setState(() {
                          this._formData["rate"] = double.parse(value);
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AssetField(
                      label: "Fee Currency",
                      initialValue: this.feeAsset,
                      onChange: (Asset asset) {
                        setState(() {
                          this.feeAsset = asset;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Fee",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      // initialValue: this._formData["fee"],
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
                ],
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
    final rate = this._formData["rate"] as double;
    final receivedQuantity = this._formData["amount"] as double;
    final feeQuantity = this._formData["fee"];

    String type = Transaction.TYPE_CONVERT;
    if (this.sentAsset.type == Asset.TYPE_FIAT) {
      type = Transaction.TYPE_BUY;
    } else if (this.receivedAsset.type == Asset.TYPE_FIAT) {
      type = Transaction.TYPE_SELL;
    }

    final transaction = Transaction(
      id: Uuid().v1(),
      type: type,
      date: selectedDate.toUtc(),
      sentAsset: this.sentAsset,
      sentQuantity: receivedQuantity * rate,
      receivedAsset: this.receivedAsset,
      receivedQuantity: receivedQuantity,
      feeAsset: this.feeAsset,
      feeQuantity: feeQuantity,
    );

    await transaction.save();
  }
}
