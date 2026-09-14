import '../../../core/localization/translation_keys.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/visa_application.dart';

extension VisaStageDisplay on VisaStage {
  String get labelKey => switch (this) {
    VisaStage.caseOpened => Tr.visaStageCase,
    VisaStage.docsRequired => Tr.visaStageDocsRequired,
    VisaStage.docsCollected => Tr.visaStageDocsCollected,
    VisaStage.submitted => Tr.visaStageSubmitted,
    VisaStage.processing => Tr.visaStageProcessing,
    VisaStage.approved => Tr.visaStageApproved,
    VisaStage.rejected => Tr.visaStageRejected,
  };

  ChipTone get tone => switch (this) {
    VisaStage.caseOpened => ChipTone.neutral,
    VisaStage.docsRequired => ChipTone.signal,
    VisaStage.docsCollected => ChipTone.info,
    VisaStage.submitted => ChipTone.info,
    VisaStage.processing => ChipTone.signal,
    VisaStage.approved => ChipTone.brand,
    VisaStage.rejected => ChipTone.critical,
  };
}

/// The stages shown as filter chips / a timeline (terminal states excluded from
/// the linear track).
const visaTrack = [
  VisaStage.caseOpened,
  VisaStage.docsRequired,
  VisaStage.docsCollected,
  VisaStage.submitted,
  VisaStage.processing,
];
