import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class AccountManagementEvent extends Equatable {
  const AccountManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the user's data export and delivery (download/share).
///
/// [sharePositionOrigin] anchors the iPad share sheet to the tapped widget and
/// is forwarded to the saver; it is null (and ignored) on other platforms.
class AccountManagementExportRequested extends AccountManagementEvent {
  const AccountManagementExportRequested({this.sharePositionOrigin});

  final Rect? sharePositionOrigin;

  @override
  List<Object?> get props => [sharePositionOrigin];
}

/// Requests permanent deletion of the authenticated account.
class AccountManagementDeleteRequested extends AccountManagementEvent {
  const AccountManagementDeleteRequested();
}
