import "package:flutter/material.dart";

import "package:cryptarch/models/models.dart" show Account;
import "package:cryptarch/widgets/widgets.dart";

class EditAccountPage extends StatefulWidget {
  final Account account;

  EditAccountPage({
    Key key,
    @required this.account,
  })  : assert(account != null),
        super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("Edit Account"),
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
                      initialValue: this.widget.account.name,
                      onSaved: (String value) {
                        setState(() {
                          this.widget.account.name = value;
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
                        labelText: "Amount",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      initialValue: this.widget.account.amount.toString(),
                      onSaved: (String value) {
                        setState(() {
                          this.widget.account.amount = double.parse(value);
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
                              await this.widget.account.save();
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
                          await this.widget.account.delete();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
