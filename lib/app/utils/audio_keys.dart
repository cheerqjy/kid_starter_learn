String slugifyKey(String value) {
  final normalized = value.toLowerCase().replaceAll('&', 'and');
  final slug = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return slug.replaceAll(RegExp(r'^-+|-+$'), '');
}
