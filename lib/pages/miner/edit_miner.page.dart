import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Miner;
import "package:cryptarch/widgets/widgets.dart";

class EditMinerPage extends StatefulWidget {
  final Miner miner;

  EditMinerPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _EditMinerPageState createState() => _EditMinerPageState();
}

class _EditMinerPageState extends State<EditMinerPage> {
  final _formKey = GlobalKey<FormState>();

  Miner miner;

  @override
  void initState() {
    super.initState();
    this.miner = this.widget.miner;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Edit Miner"),
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
                        enabled: this.miner.platform == "Custom",
                      ),
                      initialValue: this.miner.name,
                      onSaved: (String value) {
                        setState(() {
                          this.miner.name = value;
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
                        labelText: "Profitability",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: const Text("/ day"),
                      ),
                      initialValue: this.miner.profitability.toString(),
                      onSaved: (String value) {
                        setState(() {
                          this.miner.profitability = double.parse(value);
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
                        labelText: "Energy Consumption",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: const Text("kWh"),
                      ),
                      initialValue: this.miner.energy.toString(),
                      onSaved: (String value) {
                        setState(() {
                          this.miner.energy = double.parse(value);
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
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Active",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      dropdownColor: theme.backgroundColor,
                      value: this.miner.active ? "Yes" : "No",
                      items: <String>[
                        "Yes",
                        "No",
                      ].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          this.miner.active = value == "Yes";
                        });
                      },
                    ),
                  ),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        child: Text("Update", style: theme.textTheme.button),
                        color: theme.buttonColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            _formKey.currentState.save();
                            try {
                              await this.miner.save();
                              Navigator.pop(context);
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
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlineButton(
                      child: Text("Delete"),
                      textColor: theme.colorScheme.onPrimary,
                      borderSide: BorderSide(
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () async {
                        try {
                          await this.miner.account.delete();
                          await this.miner.delete();
                          Navigator.pop(context);
                        } catch (err) {
                          // final snackBar = SnackBar(
                          //   content: Text(err.message),
                          // );
                          // Scaffold.of(context).showSnackBar(snackBar);
                          print(err);
                        }
                      },
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
}
