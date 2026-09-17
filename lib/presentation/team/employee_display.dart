import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/employee.dart';

extension EmploymentStatusDisplay on EmploymentStatus {
  String get labelKey => switch (this) {
    EmploymentStatus.active => Tr.empStatusActive,
    EmploymentStatus.probation => Tr.empStatusProbation,
    EmploymentStatus.onLeave => Tr.empStatusOnLeave,
    EmploymentStatus.terminated => Tr.empStatusTerminated,
  };

  ChipTone get tone => switch (this) {
    EmploymentStatus.active => ChipTone.brand,
    EmploymentStatus.probation => ChipTone.info,
    EmploymentStatus.onLeave => ChipTone.signal,
    EmploymentStatus.terminated => ChipTone.critical,
  };
}
