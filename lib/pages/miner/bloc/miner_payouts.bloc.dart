import "package:flutter/foundation.dart";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "package:cryptarch/models/models.dart" show Payout;

part "miner_payouts.event.dart";
part "miner_payouts.state.dart";

class MinerPayoutsBloc extends Bloc<MinerPayoutsEvent, MinerPayoutsState> {
  MinerPayoutsBloc() : super(MinerPayoutsLoading());

  @override
  Stream<MinerPayoutsState> mapEventToState(MinerPayoutsEvent event) async* {
    final currentState = state;
    if (event is MinerPayoutsFetch && !this._hasReachedMax(currentState)) {
      try {
        if (currentState is MinerPayoutsLoading) {
          final payouts = await this._fetchPayouts(event.filters, 0, 20);
          yield MinerPayoutsLoaded(payouts: payouts, hasReachedMax: false);
          return;
        }
        if (currentState is MinerPayoutsLoaded) {
          final payouts = await this._fetchPayouts(
            event.filters,
            currentState.payouts.length,
            20,
          );
          yield payouts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : MinerPayoutsLoaded(
                  payouts: currentState.payouts + payouts,
                  hasReachedMax: false,
                );
        }
      } catch (err) {
        yield MinerPayoutsErrored(error: err);
      }
    }
  }

  bool _hasReachedMax(MinerPayoutsState state) =>
      state is MinerPayoutsLoaded && state.hasReachedMax;

  Future<List<Payout>> _fetchPayouts(
    Map<String, dynamic> filters,
    int offset,
    int limit,
  ) async {
    final payouts = await Payout.find(
      filters: filters,
      offset: offset,
      limit: limit,
    );
    return payouts;
  }
}
