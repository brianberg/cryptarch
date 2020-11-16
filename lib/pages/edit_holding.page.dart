import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Holding;

class EditHoldingPage extends StatefulWidget {
  final Holding holding;

  EditHoldingPage({
    Key key,
    @required this.holding,
  })  : assert(holding != null),
        super(key: key);

  @override
  _EditHoldingPageState createState() => _EditHoldingPageState();
}

class _EditHoldingPageState extends State<EditHoldingPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Holding"),
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
                        labelText: "Amount",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      initialValue: this.widget.holding.amount.toString(),
                      onSaved: (String value) {
                        setState(() {
                          this.widget.holding.amount = double.parse(value);
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
                        labelText: "Location",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      initialValue: this.widget.holding.location,
                      onSaved: (String value) {
                        setState(() {
                          this.widget.holding.location = value;
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
                              await this.widget.holding.save();
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
                        if (_formKey.currentState.validate()) {
                          // Process data.
                          _formKey.currentState.save();
                          try {
                            await this.widget.holding.delete();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
