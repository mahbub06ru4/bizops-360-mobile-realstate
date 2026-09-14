import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/task_item.dart';

/// Presentation mapping for task enums — label key + chip tone. Kept out of the
/// domain entity (which stays UI-agnostic).
extension TaskStatusDisplay on TaskStatus {
  String get labelKey => switch (this) {
    TaskStatus.open => Tr.taskStatusOpen,
    TaskStatus.inProgress => Tr.taskStatusInProgress,
    TaskStatus.blocked => Tr.taskStatusBlocked,
    TaskStatus.done => Tr.taskStatusDone,
  };

  ChipTone get tone => switch (this) {
    TaskStatus.open => ChipTone.neutral,
    TaskStatus.inProgress => ChipTone.info,
    TaskStatus.blocked => ChipTone.critical,
    TaskStatus.done => ChipTone.brand,
  };
}

extension TaskPriorityDisplay on TaskPriority {
  String get labelKey => switch (this) {
    TaskPriority.low => Tr.taskPriorityLow,
    TaskPriority.normal => Tr.taskPriorityNormal,
    TaskPriority.high => Tr.taskPriorityHigh,
    TaskPriority.urgent => Tr.taskPriorityUrgent,
  };

  ChipTone get tone => switch (this) {
    TaskPriority.low => ChipTone.neutral,
    TaskPriority.normal => ChipTone.neutral,
    TaskPriority.high => ChipTone.signal,
    TaskPriority.urgent => ChipTone.critical,
  };
}
