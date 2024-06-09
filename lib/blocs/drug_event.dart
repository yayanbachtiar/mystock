import 'package:equatable/equatable.dart';

// Event
abstract class DrugsEvent extends Equatable {
  const DrugsEvent();

  @override
  List<Object?> get props => [];
}

class FetchDrugs extends DrugsEvent {}
