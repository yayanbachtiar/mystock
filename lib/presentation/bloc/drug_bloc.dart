import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mystok/data/repositories/drug_repository.dart';
import 'package:mystok/data/models/drug_model.dart';

// Event
abstract class DrugsEvent {}

class FetchDrugs extends DrugsEvent {}

// State
abstract class DrugsState {}

class DrugsInitial extends DrugsState {}

class DrugsLoading extends DrugsState {}

class DrugsLoaded extends DrugsState {
  final List<Drug> drugs;

  DrugsLoaded(this.drugs);
}

class DrugsError extends DrugsState {
  final String message;

  DrugsError(this.message);
}

// Bloc
class DrugsBloc extends Bloc<DrugsEvent, DrugsState> {
  final DrugRepository drugRepository;

  DrugsBloc(this.drugRepository) : super(DrugsInitial());

  @override
  Stream<DrugsState> mapEventToState(DrugsEvent event) async* {
    if (event is FetchDrugs) {
      yield DrugsLoading();
      try {
        final List<Drug> drugs = await drugRepository.fetchDrugs("");
        yield DrugsLoaded(drugs);
      } catch (e) {
        yield DrugsError('Failed to fetch drugs: $e');
      }
    }
  }
}
