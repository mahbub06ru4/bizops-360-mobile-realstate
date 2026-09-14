import 'package:flutter/material.dart';

import '../../core/localization/translation_keys.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/follow_up.dart';

extension PipelineStageDisplay on PipelineStage {
  String get labelKey => switch (this) {
    PipelineStage.newLead => Tr.stageNewLead,
    PipelineStage.contacted => Tr.stageContacted,
    PipelineStage.interested => Tr.stageInterested,
    PipelineStage.followUp => Tr.stageFollowUp,
    PipelineStage.negotiation => Tr.stageNegotiation,
    PipelineStage.converted => Tr.stageConverted,
    PipelineStage.lost => Tr.stageLost,
  };

  ChipTone get tone => switch (this) {
    PipelineStage.newLead => ChipTone.neutral,
    PipelineStage.contacted => ChipTone.info,
    PipelineStage.interested => ChipTone.info,
    PipelineStage.followUp => ChipTone.signal,
    PipelineStage.negotiation => ChipTone.signal,
    PipelineStage.converted => ChipTone.brand,
    PipelineStage.lost => ChipTone.critical,
  };
}

extension FollowUpChannelDisplay on FollowUpChannel {
  IconData get icon => switch (this) {
    FollowUpChannel.call => Icons.call_outlined,
    FollowUpChannel.whatsapp => Icons.chat_outlined,
    FollowUpChannel.email => Icons.mail_outlined,
    FollowUpChannel.meeting => Icons.groups_outlined,
    FollowUpChannel.visit => Icons.place_outlined,
  };
}

extension FollowUpOutcomeDisplay on FollowUpOutcome {
  String get labelKey => switch (this) {
    FollowUpOutcome.reached => Tr.outcomeReached,
    FollowUpOutcome.noAnswer => Tr.outcomeNoAnswer,
    FollowUpOutcome.rescheduled => Tr.outcomeRescheduled,
    FollowUpOutcome.notInterested => Tr.outcomeNotInterested,
    FollowUpOutcome.won => Tr.outcomeWon,
  };
}
