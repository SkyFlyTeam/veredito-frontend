String removeHtmlTags(String input) {
  final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return input.replaceAll(regex, '');
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}