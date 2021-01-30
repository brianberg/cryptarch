import "dart:io";

import "package:flutter/material.dart";

import "package:file_picker/file_picker.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:cryptarch/models/models.dart" show Miner, Payout;
import "package:cryptarch/services/services.dart" show CsvService;
import "package:cryptarch/widgets/widgets.dart";

import "bloc/miner_payouts.bloc.dart";

class MinerPayoutsPage extends StatefulWidget {
  final Miner miner;

  MinerPayoutsPage({
    Key key,
    @required this.miner,
  })  : assert(miner != null),
        super(key: key);

  @override
  _MinerPayoutsPageState createState() => _MinerPayoutsPageState();
}

class _MinerPayoutsPageState extends State<MinerPayoutsPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  MinerPayoutsBloc _payoutsBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _payoutsBloc = MinerPayoutsBloc()
      ..add(
        MinerPayoutsFetch(
          filters: {
            "minerId": this.widget.miner.id,
          },
          orderBy: "date DESC",
        ),
      );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlatAppBar(
        title: Text("${this.widget.miner.name} Payouts"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () async {
              try {
                final file = await this._export();
                if (file != null) {
                  print("successfully exported payouts");
                  // TODO: show success alert
                }
              } catch (err) {
                print("unable to export payouts: $err");
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<MinerPayoutsBloc, MinerPayoutsState>(
          cubit: this._payoutsBloc,
          builder: (context, state) {
            if (state is MinerPayoutsErrored) {
              return Center(
                child: Text("Unable to get payouts"),
              );
            }
            if (state is MinerPayoutsLoaded) {
              if (state.payouts.isEmpty) {
                return Center(
                  child: Text("No payouts"),
                );
              }
              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.payouts.length
                      ? LoadingIndicator()
                      : PayoutListItem(payout: state.payouts[index]);
                },
                itemCount: state.hasReachedMax
                    ? state.payouts.length
                    : state.payouts.length + 1,
                controller: _scrollController,
              );
            }

            return LoadingIndicator();
          },
        ),
      ),
    );
  }

  Future<File> _export() async {
    final miner = this.widget.miner;
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      List<Payout> payouts = await Payout.find(
        filters: {
          "minerId": miner.id,
        },
        orderBy: "date DESC",
      );
      List<List<dynamic>> rows = payouts
          .map(
            (payout) => payout.toCsv(),
          )
          .toList();
      String minerName = miner.name.replaceAll(" ", "-").toLowerCase();
      String filepath = "$path/${minerName}_payouts.csv";
      return CsvService.export(
        filepath,
        rows,
        headers: Payout.csvHeaders,
        appendTimestamp: true,
      );
    }

    return null;
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _payoutsBloc.add(
        MinerPayoutsFetch(
          filters: {
            "minerId": this.widget.miner.id,
          },
          orderBy: "date DESC",
        ),
      );
    }
  }
}
