import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/employee.dart';

extension EmploymentStatusDisplay on EmploymentStatus {
  String get labelKey => switch (this) {
    EmploymentStatus.active => Tr.empStatusActive,
    EmploymentStatus.onLeave => Tr.empStatusOnLeave,
    EmploymentStatus.inactive => Tr.empStatusInactive,
  };

  ChipTone get tone => switch (this) {
    EmploymentStatus.active => ChipTone.brand,
    EmploymentStatus.onLeave => ChipTone.signal,
    EmploymentStatus.inactive => ChipTone.neutral,
  };
}
