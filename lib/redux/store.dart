import 'package:redux/redux.dart';
import 'reducer.dart';
import 'state.dart';

final Store<AppState> store = Store<AppState>(
  appReducer,
  initialState: AppState(),
);