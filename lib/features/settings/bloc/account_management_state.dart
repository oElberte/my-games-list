import 'package:equatable/equatable.dart';

enum AccountActionStatus { idle, loading, success, failure }

class AccountManagementState extends Equatable {
  const AccountManagementState({
    this.exportStatus = AccountActionStatus.idle,
    this.deleteStatus = AccountActionStatus.idle,
    this.errorMessage,
  });

  final AccountActionStatus exportStatus;
  final AccountActionStatus deleteStatus;
  final String? errorMessage;

  bool get isBusy =>
      exportStatus == AccountActionStatus.loading ||
      deleteStatus == AccountActionStatus.loading;

  AccountManagementState copyWith({
    AccountActionStatus? exportStatus,
    AccountActionStatus? deleteStatus,
    String? errorMessage,
  }) {
    return AccountManagementState(
      exportStatus: exportStatus ?? this.exportStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [exportStatus, deleteStatus, errorMessage];
}
