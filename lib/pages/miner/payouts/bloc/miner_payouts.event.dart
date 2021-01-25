part of "miner_payouts.bloc.dart";

abstract class MinerPayoutsEvent extends Equatable {
  const MinerPayoutsEvent();

  @override
  List<Object> get props => [];
}

class MinerPayoutsFetch extends MinerPayoutsEvent {
  final Map<String, dynamic> filters;
  final String orderBy;

  MinerPayoutsFetch({
    @required this.filters,
    this.orderBy,
  })  : assert(filters != null),
        super();

  @override
  List<Object> get props => [filters, orderBy];

  @override
  String toString() => "MinerPayoutsPageFetch";
}
