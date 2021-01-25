part of "miner_payouts.bloc.dart";

abstract class MinerPayoutsState extends Equatable {
  const MinerPayoutsState();

  @override
  List<Object> get props => [];
}

class MinerPayoutsLoading extends MinerPayoutsState {
  @override
  String toString() => "MinerPayoutsLoading";
}

class MinerPayoutsErrored extends MinerPayoutsState {
  final Exception error;

  MinerPayoutsErrored({
    this.error,
  }) : super();

  @override
  List<Object> get props => [error];

  @override
  String toString() => "MinerPayoutsError: ${error.toString()}";
}

class MinerPayoutsLoaded extends MinerPayoutsState {
  final List<Payout> payouts;
  final bool hasReachedMax;

  MinerPayoutsLoaded({
    @required this.payouts,
    @required this.hasReachedMax,
  })  : assert(payouts != null),
        assert(hasReachedMax != null),
        super();

  MinerPayoutsLoaded copyWith({
    List<Payout> payouts,
    bool hasReachedMax,
  }) {
    return MinerPayoutsLoaded(
      payouts: payouts ?? this.payouts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [payouts, hasReachedMax];

  @override
  String toString() =>
      "MinerPayoutsLoaded { payouts: ${payouts.length}, hasReachedMax: $hasReachedMax }";
}
