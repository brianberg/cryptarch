import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart" show InventoryItem;
import "package:cryptarch/widgets/widgets.dart";

class InventoryAddPage extends StatefulWidget {
  static String routeName = "/inventory_add";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => InventoryAddPage(),
    );
  }

  @override
  _InventoryAddPageState createState() => _InventoryAddPageState();
}

class _InventoryAddPageState extends State<InventoryAddPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Add Item"),
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
                      initialValue: this._formData["name"],
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
                      keyboardType: TextInputType.number,
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Cost",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: Text("USD"),
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["cost"] = double.parse(value);
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
                      keyboardType: TextInputType.number,
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      initialValue: "1",
                      onSaved: (String value) {
                        setState(() {
                          this._formData["quantity"] = int.parse(value);
                        });
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Required";
                        } else if (int.tryParse(value) == null) {
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
                              await _saveItem();
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

  Future<void> _saveItem() async {
    final item = InventoryItem(
      id: Uuid().v1(),
      name: this._formData["name"],
      cost: this._formData["cost"],
      quantity: this._formData["quantity"],
    );

    await item.save();
  }
}
