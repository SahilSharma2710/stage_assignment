import 'package:equatable/equatable.dart';

enum ConnectionStatus { initial, connected, disconnected }

class ConnectivityState extends Equatable {
  final ConnectionStatus status;

  const ConnectivityState({
    this.status = ConnectionStatus.initial,
  });

  ConnectivityState copyWith({
    ConnectionStatus? status,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;

  @override
  List<Object> get props => [status];
}
