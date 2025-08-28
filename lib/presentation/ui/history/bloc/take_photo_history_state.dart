import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/math.dart';

abstract class TakePhotoHistoryState extends Equatable {
  const TakePhotoHistoryState();

  @override
  List<Object?> get props => [];
}

class TakePhotoHistoryInitial extends TakePhotoHistoryState {
  const TakePhotoHistoryInitial();
}

class TakePhotoHistoryLoading extends TakePhotoHistoryState {
  final List<Math> takePhotoHistoryItems;

  const TakePhotoHistoryLoading({this.takePhotoHistoryItems = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TakePhotoHistoryLoading &&
        listEquals(other.takePhotoHistoryItems, takePhotoHistoryItems);
  }

  @override
  int get hashCode => takePhotoHistoryItems.hashCode;
}

class TakePhotoHistoryLoaded extends TakePhotoHistoryState {
  final List<Math> takePhotoHistoryItems;
  final Map<int, bool> selectedItems;
  final bool isSelectionMode;

  // Remove 'const' from the constructor
  TakePhotoHistoryLoaded({
    required this.takePhotoHistoryItems,
    Map<int, bool>? selectedItems,
    this.isSelectionMode = false,
  }) : selectedItems = selectedItems ?? const {};

  TakePhotoHistoryLoaded copyWith({
    List<Math>? takePhotoHistoryItems,
    Map<int, bool>? selectedItems,
    bool? isSelectionMode,
  }) {
    return TakePhotoHistoryLoaded(
      takePhotoHistoryItems: takePhotoHistoryItems ?? this.takePhotoHistoryItems,
      selectedItems: selectedItems ?? this.selectedItems,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TakePhotoHistoryLoaded &&
        listEquals(other.takePhotoHistoryItems, takePhotoHistoryItems) &&
        mapEquals(other.selectedItems, selectedItems) &&
        other.isSelectionMode == isSelectionMode;
  }

  @override
  int get hashCode =>
      takePhotoHistoryItems.hashCode ^ selectedItems.hashCode ^ isSelectionMode.hashCode;
}

class TakePhotoHistoryError extends TakePhotoHistoryState {
  final String message;

  const TakePhotoHistoryError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TakePhotoHistoryError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}