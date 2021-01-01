import "package:flutter/material.dart";

import "package:uuid/uuid.dart";

import "package:cryptarch/models/models.dart"
    show Asset, Account, Miner, Payout;
import "package:cryptarch/services/services.dart"
    show NiceHashService, NiceHashPayout, StorageService;
import "package:cryptarch/widgets/widgets.dart";

class AddNiceHashMinerPage extends StatefulWidget {
  @override
  _AddNiceHashMinerPageState createState() => _AddNiceHashMinerPageState();
}

class _AddNiceHashMinerPageState extends State<AddNiceHashMinerPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FlatAppBar(
        title: const Text("NiceHash"),
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
                      cursorColor: theme.cursorColor,
                      decoration: InputDecoration(
                        labelText: "Organization ID",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["organization_id"] = value;
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
                        labelText: "API Key",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["api_key"] = value;
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
                        labelText: "API Secret",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      onSaved: (String value) {
                        setState(() {
                          this._formData["api_secret"] = value;
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
                        labelText: "Energy Consumption",
                        filled: true,
                        fillColor: theme.cardTheme.color,
                        suffix: const Text("kWh"),
                      ),
                      initialValue: "0",
                      onSaved: (String value) {
                        setState(() {
                          this._formData["energy"] = double.parse(value);
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
                        child: Text("Add", style: theme.textTheme.button),
                        color: theme.buttonColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            // Process data.
                            _formKey.currentState.save();
                            try {
                              // Create miner and account
                              final miner = await _saveNiceHashMiner();
                              if (miner != null) {
                                Navigator.pop(context, miner.id);
                              }
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

  Future<Miner> _saveNiceHashMiner() async {
    // Securely store NiceHash credentials
    final credentials = {
      "organization_id": this._formData["organization_id"],
      "api_key": this._formData["api_key"],
      "api_secret": this._formData["api_secret"],
    };
    await StorageService.putItem(
      "nicehash",
      credentials,
    );

    final nicehash = NiceHashService();
    final balance = await nicehash.getAccountBalance();
    final profitability = await nicehash.getProfitability();
    final uuid = Uuid();

    final asset = await Asset.findOneBySymbol("BTC");

    // TODO: add bitcoin if not found

    final account = Account(
      id: uuid.v1(),
      name: "NiceHash",
      asset: asset,
      amount: balance.available,
    );
    await account.save();

    final miner = Miner(
      id: uuid.v1(),
      name: "NiceHash",
      platform: "NiceHash",
      asset: asset,
      account: account,
      profitability: profitability,
      energy: this._formData["energy"],
      active: true,
      unpaidAmount: balance.pending,
    );
    await miner.save();

    try {
      await this._getMiningPayouts(miner, asset);
      return miner;
    } catch (err) {
      await Payout.deleteMany({"minerId": miner.id});
      await miner.delete();
      await account.delete();
      return null;
    }
  }

  Future<void> _getMiningPayouts(Miner miner, Asset asset) async {
    final uuid = Uuid();
    final nicehash = NiceHashService();
    final DateTime now = DateTime.now();
    final int pageSize = 168; // 4 weeks * 7 days * 6 payouts per day

    // Keep track of the previous page's last payout
    // in case the next page has payouts on the same day
    Payout currentPayout;
    List<NiceHashPayout> payouts;
    int afterMillis = now.toUtc().millisecondsSinceEpoch;
    do {
      // Get a page of payouts
      payouts = await nicehash.getPayouts(
        pageSize: pageSize,
        afterMillis: afterMillis,
      );
      // Aggregate payouts by day
      DateTime firstDate;
      DateTime lastDate;
      final Map<DateTime, Payout> daily = {};
      for (NiceHashPayout payout in payouts) {
        // Only care about payouts to the user (mining payouts)
        if (payout.accountType == NiceHashService.PAYOUT_USER) {
          final created = payout.created.toLocal();
          final date = DateTime(created.year, created.month, created.day);
          final existingPayout = daily[date];
          if (existingPayout == null) {
            daily[date] = Payout(
              id: uuid.v1(),
              miner: miner,
              asset: asset,
              date: date,
              amount: payout.amount,
            );
          } else {
            existingPayout.amount += payout.amount;
            daily[date] = existingPayout;
          }
          // Keep track of first and last date of page
          if (payout.id == payouts.first.id) {
            firstDate = date;
          } else if (payout.id == payouts.last.id) {
            lastDate = date;
            afterMillis = created.millisecondsSinceEpoch;
          }
        }
      }
      // Save payouts
      for (Payout payout in daily.values) {
        // If payout is on the same day as current payout add to it instead
        if (payout.date == firstDate && currentPayout?.date == firstDate) {
          currentPayout.amount += payout.amount;
          await currentPayout.save();
        } else {
          await payout.save();
        }
      }
      // Set current payout to the last payout of this page
      currentPayout = daily[lastDate];
    } while (payouts.length == pageSize);
  }
}
