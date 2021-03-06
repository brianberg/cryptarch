import "package:flutter/material.dart";
import "package:flutter/foundation.dart";

import "package:intl/intl.dart";
import "package:file_picker/file_picker.dart";
import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show Miner, Payout;
import "package:cryptarch/services/services.dart" show CsvService;
import "package:cryptarch/widgets/widgets.dart";

class PayoutAddPage extends StatefulWidget {
  static String routeName = "/payout_add";

  static Route route(Miner miner) {
    return MaterialPageRoute<void>(
      builder: (_) => PayoutAddPage(miner: miner),
    );
  }

  final Miner miner;

  PayoutAddPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _PayoutAddPageState createState() => _PayoutAddPageState();
}

class _PayoutAddPageState extends State<PayoutAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateInputController = TextEditingController();
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");

  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      this._formData["date"] = DateTime.now().subtract(Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final miner = this.widget.miner;
    final selectedDate = this._formData["date"];
    this._dateInputController.text = this.dateFormat.format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payout"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null) {
                final path = result.files.first.path;
                this._showImportDialog(context, this._importPayouts(path));
              }
            },
          )
        ],
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
                      keyboardType: TextInputType.number,
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: Text(miner.asset.symbol),
                      ),
                      initialValue: "0",
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
                              final amount = this._formData["amount"];
                              final selectedDate =
                                  this._formData["date"] as DateTime;
                              final date = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              );
                              // Add to existing payout
                              final existing = await Payout.find(filters: {
                                "minerId": miner.id,
                                "date": date.millisecondsSinceEpoch,
                              });
                              if (existing.isNotEmpty) {
                                final payout = existing.first;
                                payout.amount += amount;
                                await payout.save();
                              } else {
                                final payout = Payout(
                                  id: Uuid().v1(),
                                  miner: miner,
                                  asset: miner.asset,
                                  date: date,
                                  amount: amount,
                                );
                                await payout.save();
                              }
                              Navigator.pop(context);
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

  Future<void> _importPayouts(String path) async {
    if (path != null) {
      final rows = await CsvService.import(path);
      if (rows.isNotEmpty) {
        if (listEquals(rows.first, Payout.csvHeaders)) {
          rows.removeAt(0);
        }
        List<Payout> payouts = List<Payout>.from(rows.map((csvRow) {
          return Payout.fromCsv(csvRow, this.widget.miner);
        })).toList();
        for (Payout payout in payouts) {
          final existing = await Payout.find(filters: {
            "minerId": this.widget.miner.id,
            "date": payout.date.millisecondsSinceEpoch,
          });
          // Delete existing
          if (existing.isNotEmpty) {
            await existing.first.delete();
          }
          await payout.save();
        }
      }
    }
  }

  Future<dynamic> _showImportDialog(
    BuildContext context,
    Future future,
  ) async {
    final dialog = AlertDialog(
      title: Text("Importing payouts"),
      content: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return LoadingIndicator();
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              return Text("Successfully imported payouts");
          }
          return Container(child: const Text("Unable to import payouts"));
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "OK",
            style: TextStyle(
              color: Theme.of(context).textTheme.button.color,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    return showDialog<dynamic>(context: context, builder: (context) => dialog);
  }
}
