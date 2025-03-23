import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc() : super(const ConnectivityState()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ConnectionChanged>(_onConnectionChanged);

    // Subscribe to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectionChanged(result[0] != ConnectivityResult.none));
    });
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult[0] != ConnectivityResult.none;
      emit(state.copyWith(
        status: isConnected
            ? ConnectionStatus.connected
            : ConnectionStatus.disconnected,
      ));
    } catch (_) {
      emit(state.copyWith(status: ConnectionStatus.disconnected));
    }
  }

  void _onConnectionChanged(
    ConnectionChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(state.copyWith(
      status: event.isConnected
          ? ConnectionStatus.connected
          : ConnectionStatus.disconnected,
    ));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
