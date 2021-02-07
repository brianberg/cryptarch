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
          final payouts = await Payout.find(
            filters: event.filters,
            orderBy: event.orderBy,
            limit: 20,
          );
          yield MinerPayoutsLoaded(payouts: payouts, hasReachedMax: false);
          return;
        }
        if (currentState is MinerPayoutsLoaded) {
          final payouts = await Payout.find(
            filters: event.filters,
            orderBy: event.orderBy,
            offset: currentState.payouts.length,
            limit: 20,
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
}
