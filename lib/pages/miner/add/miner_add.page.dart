import "package:flutter/material.dart";

import "package:cryptarch/pages/pages.dart";

class MinerAddPage extends StatefulWidget {
  static String routeName = "/miner_add";

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => MinerAddPage(),
    );
  }

  @override
  _MinerAddPageState createState() => _MinerAddPageState();
}

class _MinerAddPageState extends State<MinerAddPage> {
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
                                MinerAddNiceHashPage.route(),
                              );
                              break;
                            case "Ethermine":
                              minerId = await Navigator.push(
                                context,
                                MinerAddEtherminePage.route(),
                              );
                              break;
                            default:
                              minerId = await Navigator.push(
                                context,
                                MinerAddCustomPage.route(),
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
