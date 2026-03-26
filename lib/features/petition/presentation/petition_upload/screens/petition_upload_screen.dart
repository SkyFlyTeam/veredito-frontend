import 'package:flutter/material.dart';

import '../../../../../shared/layouts/page_layout.dart';
import '../widgets/petition_upload_card.dart';

class PetitionUploadScreen extends StatelessWidget {
  const PetitionUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      child: Center(
        child: PetitionUploadCard(),
      ),
    );
  }
}
