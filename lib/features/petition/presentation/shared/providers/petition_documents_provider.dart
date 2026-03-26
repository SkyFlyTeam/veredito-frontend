import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/peticao_document.dart';

final petitionDocumentsProvider = StateProvider<List<PeticaoDocument>>(
  // TODO: substituir por chamada real à API quando o backend estiver pronto.
  (ref) => mockPeticaoDocuments,
);
