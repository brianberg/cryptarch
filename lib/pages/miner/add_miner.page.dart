import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";

class AddMinerPage extends StatefulWidget {
  @override
  _AddMinerPageState createState() => _AddMinerPageState();
}

class _AddMinerPageState extends State<AddMinerPage> {
  final _formKey = GlobalKey<FormState>();

  String platform = "Custom";
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    this._formData["platform"] = "Custom";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Miner"),
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
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Platform",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      dropdownColor: theme.backgroundColor,
                      value: this._formData["platform"].toString(),
                      items: <String>[
                        "Custom",
                        "Ethermine",
                        "NiceHash",
                      ].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          this.platform = value;
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
                        child: Text("Next", style: theme.textTheme.button),
                        color: theme.buttonColor,
                        onPressed: () async {
                          String minerId;
                          switch (this.platform) {
                            case "NiceHash":
                              minerId = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNiceHashMinerPage(),
                                ),
                              );
                              break;
                            case "Ethermine":
                              minerId = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEthermineMinerPage(),
                                ),
                              );
                              break;
                            default:
                              minerId = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCustomMinerPage(),
                                ),
                              );
                              break;
                          }

                          Navigator.pop(context, minerId);
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
}
