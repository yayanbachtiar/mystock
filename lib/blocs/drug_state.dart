import 'package:equatable/equatable.dart';
import 'package:mystok/data/models/drug_model.dart';

abstract class DrugState extends Equatable {
  const DrugState();

  @override
  List<Object?> get props => [];
}

class DrugsInitial extends DrugState {}

class DrugsLoading extends DrugState {}

class DrugsLoaded extends DrugState {
  final List<Drug> drugs;

  const DrugsLoaded(this.drugs);

  @override
  List<Object?> get props => [drugs];
}

class DrugsError extends DrugState {
  final String message;

  const DrugsError(this.message);
}
