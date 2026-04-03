import 'dart:convert';

String extractOriginalFileNameFromPath(String path) {
  final trimmedPath = path.trim();
  if (trimmedPath.isEmpty) {
    return 'Arquivo não disponível';
  }

  final pathSegments = trimmedPath.split(RegExp(r'[\\/]'));
  final baseName = pathSegments.isNotEmpty ? pathSegments.last : trimmedPath;

  final nameSegments = baseName.split('-');
  if (nameSegments.length <= 2) {
    return _repairMojibake(baseName);
  }

  // Backend format:
  // <timestamp>-<random>-original-file-name.pdf
  // Remove only first two parts and preserve any '-' in the real filename.
  final rawFileName = nameSegments.sublist(2).join('-');
  return _repairMojibake(rawFileName);
}

String _repairMojibake(String value) {
  if (value.isEmpty) {
    return value;
  }

  // Common signal that UTF-8 text was decoded as Latin-1/Windows-1252.
  final hasMojibakeHints =
      value.contains('Ã') || value.contains('Â') || value.contains('â');
  if (!hasMojibakeHints) {
    return value;
  }

  try {
    return utf8.decode(latin1.encode(value), allowMalformed: true);
  } catch (_) {
    return value;
  }
}
