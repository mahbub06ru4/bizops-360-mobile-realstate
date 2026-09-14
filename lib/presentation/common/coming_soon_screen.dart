import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/widgets.dart';

/// Full-screen "not built yet" target for Workspace entries whose slice is
/// still ahead on the roadmap. Title comes from `Get.arguments`.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Get.arguments is String ? Get.arguments as String : '';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ComingSoon(label: title.isEmpty ? null : title),
    );
  }
}
