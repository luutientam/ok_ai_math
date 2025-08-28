import 'package:equatable/equatable.dart';

import '../../../../domain/models/math.dart';

abstract class TakePhotoHistoryEvent extends Equatable {
  const TakePhotoHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadTakePhotoHistory extends TakePhotoHistoryEvent {
  const LoadTakePhotoHistory();
}

class DeleteTakePhotoHistoryItem extends TakePhotoHistoryEvent {
  final int id;

  const DeleteTakePhotoHistoryItem(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteSelectedTakePhotoHistoryItems extends TakePhotoHistoryEvent {
  final List<int> ids;

  const DeleteSelectedTakePhotoHistoryItems(this.ids);

  @override
  List<Object?> get props => [ids];
}

class ToggleTakePhotoHistorySelection extends TakePhotoHistoryEvent {
  final Math item;
  final bool isSelected;

  const ToggleTakePhotoHistorySelection(this.item, this.isSelected);

  @override
  List<Object?> get props => [item.uid, isSelected];
}

class ToggleSelectionMode extends TakePhotoHistoryEvent {
  final bool enable;

  const ToggleSelectionMode({required this.enable});

  @override
  List<Object?> get props => [enable];
}

class SelectAllTakePhotoHistoryItems extends TakePhotoHistoryEvent {
  final bool selectAll; // true = chọn tất cả, false = bỏ chọn tất cả

  const SelectAllTakePhotoHistoryItems(this.selectAll);

  @override
  List<Object?> get props => [selectAll];
}

class ToggleSelectByDate extends TakePhotoHistoryEvent {
  final DateTime date;      // ngày cần chọn/bỏ chọn
  final bool isSelected;    // true = chọn hết, false = bỏ chọn

  const ToggleSelectByDate(this.date, this.isSelected);

  @override
  List<Object?> get props => [date, isSelected];
}

class DeleteAllTakePhotoHistoryItems extends TakePhotoHistoryEvent {
  const DeleteAllTakePhotoHistoryItems();

  @override
  List<Object?> get props => [];
}