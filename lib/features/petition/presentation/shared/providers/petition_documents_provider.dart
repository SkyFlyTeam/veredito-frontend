import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/peticao_document.dart';

final petitionDocumentsProvider = StateProvider<List<PeticaoDocument>>(
  // TODO: replace with a real API call when the backend is ready.
  (ref) => [],
);
