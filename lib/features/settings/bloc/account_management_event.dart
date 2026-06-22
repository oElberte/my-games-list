import 'package:equatable/equatable.dart';

abstract class AccountManagementEvent extends Equatable {
  const AccountManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the user's data export and delivery (download/share).
class AccountManagementExportRequested extends AccountManagementEvent {
  const AccountManagementExportRequested();
}

/// Requests permanent deletion of the authenticated account.
class AccountManagementDeleteRequested extends AccountManagementEvent {
  const AccountManagementDeleteRequested();
}
