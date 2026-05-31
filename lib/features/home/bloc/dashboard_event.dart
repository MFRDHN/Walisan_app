import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class DashboardFetch extends DashboardEvent {
  final bool refresh;

  const DashboardFetch({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}
