import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mystok/blocs/drug_event.dart';
import 'package:mystok/blocs/drug_state.dart';

// Bloc
class DrugsBloc extends Bloc<DrugsEvent, DrugState> {
  DrugsBloc() : super(DrugsInitial()) {
    on<FetchDrugs>(
      (event, emit) async {
        emit(DrugsLoading());
      },
    );
  }
}
