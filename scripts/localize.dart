import 'dart:io';
import 'dart:convert';

final Map<String, String> translations = {};

final List<String> uiFolders = ['screens', 'pages', 'views', 'ui'];
final List<String> skipFilePatterns = ['controller', 'binding'];

void main() async {
  final libDir = Directory('lib');

  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      bool isUiFolder = uiFolders.any((folder) =>
      entity.path.contains('/$folder/') ||
          entity.path.contains('\\$folder\\'));

      bool isSkipped = skipFilePatterns.any((pattern) =>
          entity.path.toLowerCase().contains(pattern));

      if (isUiFolder && !isSkipped) {
        print("📄 Processing: ${entity.path}");
        processFile(entity);
      }
    }
  }

  saveJson();
  print("\n✅ Localization Complete — ${translations.length} keys found");
  printKeyValueTable();
}

void processFile(File file) {
  String content = file.readAsStringSync();

  // ✅ Step 1: Fix already broken .tr multiline — convert back to raw then re-process
  content = _fixAlreadyProcessedMultiline(content);

  // ✅ Step 2: Combine adjacent raw multiline strings
  content = _combineAdjacentStrings(content);

  // ✅ Step 3: Process single strings
  bool modified = false;
  final regex = RegExp(r'"((?:[^"\\]|\\.)*)"');

  content = content.replaceAllMapped(regex, (match) {
    final raw = match.group(0)!;
    final text = match.group(1)!;

    if (text.isEmpty) return raw;
    if (text.trim().isEmpty) return raw;
    if (raw.contains('.tr')) return raw;
    if (_shouldSkip(text)) return raw;
    if (text.contains(r'${') || text.contains(r'$')) return raw;

    final key = generateKey(text);
    if (key.isEmpty) return raw;

    translations[key] = text;
    modified = true;
    return '"$key".tr';
  });

  if (modified) {
    file.writeAsStringSync(content);
  }
}

// ✅ Detect and fix this broken pattern:
// "key1".tr
// "key2".tr
// "key3".tr
// → look up original values from translations and recombine OR just merge keys
String _fixAlreadyProcessedMultiline(String content) {
  // Pattern: multiple "something".tr on consecutive lines (no comma until last)
  final brokenPattern = RegExp(
    r'([ \t]*)("(?:[^"\\]|\\.)*"\.tr)\s*\n((?:[ \t]*"(?:[^"\\]|\\.)*"\.tr\s*\n?)+)',
    multiLine: true,
  );

  content = content.replaceAllMapped(brokenPattern, (match) {
    final fullMatch = match.group(0)!;
    final indent = match.group(1) ?? '';

    // Extract all .tr keys
    final keyRegex = RegExp(r'"((?:[^"\\]|\\.)*)"\.tr');
    final keys = keyRegex
        .allMatches(fullMatch)
        .map((m) => m.group(1)!)
        .toList();

    if (keys.length < 2) return fullMatch;

    // ✅ Combine all keys into one new key
    final combinedKey = keys.join('_').replaceAll(RegExp(r'_+'), '_');
    final finalKey = combinedKey.length > 60
        ? combinedKey.substring(0, 60)
        : combinedKey;

    // Try to restore original value from translations map
    final combinedValue = keys
        .map((k) => translations[k] ?? k.replaceAll('_', ' '))
        .join('');

    translations[finalKey] = combinedValue;

    print("  🔧 Fixed broken multiline → $finalKey");

    return '$indent"$finalKey".tr';
  });

  return content;
}

String _combineAdjacentStrings(String content) {
  // Match adjacent raw strings (no .tr) on consecutive lines
  final adjacentRegex = RegExp(
    r'''([ \t]*)"((?:[^"\\]|\\.)*?)"\s*\n((?:[ \t]*"(?:[^"\\]|\\.)*?"\s*\n?)+)''',
    multiLine: true,
  );

  content = content.replaceAllMapped(adjacentRegex, (match) {
    final fullMatch = match.group(0)!;

    // ❌ Skip if already has .tr anywhere
    if (fullMatch.contains('.tr')) return fullMatch;

    final indent = match.group(1) ?? '';

    final partRegex = RegExp(r'"((?:[^"\\]|\\.)*?)"');
    final parts = partRegex
        .allMatches(fullMatch)
        .map((m) => m.group(1)!)
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length < 2) return fullMatch;

    final combined = parts.join('');
    if (combined.trim().isEmpty) return fullMatch;
    if (_shouldSkip(combined)) return fullMatch;

    final key = generateKey(combined);
    if (key.isEmpty) return fullMatch;

    translations[key] = combined;
    print("  🔗 Combined ${parts.length} strings → $key");

    return '$indent"$key".tr';
  });

  return content;
}

bool _shouldSkip(String text) {
  if (text.trim().length < 2) return true;
  if (text.startsWith('assets/') || text.startsWith('lib/')) return true;
  if (RegExp(r'^/[a-zA-Z]').hasMatch(text)) return true;
  if (RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(text)) return true;
  if (RegExp(r'^#[0-9a-fA-F]{3,8}$').hasMatch(text)) return true;
  if (text.startsWith('http://') || text.startsWith('https://')) return true;
  if (RegExp(r'^[yMdHhmsS\-/:.T ]+$').hasMatch(text)) return true;
  if (RegExp(r'^[A-Z][a-zA-Z]+\.[a-zA-Z]').hasMatch(text)) return true;
  if (RegExp(r'^[^a-zA-Z]+$').hasMatch(text)) return true;
  if (RegExp(r'^[a-z]+\.[a-z]+\.[a-z]').hasMatch(text)) return true;
  return false;
}

String generateKey(String text) {
  if (text.trim().isEmpty) return '';

  final key = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  if (key.isEmpty) return '';
  return key.length > 60 ? key.substring(0, 60) : key;
}

void saveJson() {
  final sorted = Map.fromEntries(
    translations.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  final file = File('assets/lang/en.json');
  file.createSync(recursive: true);
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(sorted),
  );

  print("\n📁 Saved: assets/lang/en.json");
}

void printKeyValueTable() {
  print("\n${'─' * 80}");
  print('${'KEY'.padRight(45)} VALUE');
  print('─' * 80);
  translations.forEach((key, value) {
    final k = key.length > 43 ? '${key.substring(0, 40)}...' : key;
    final v = value.length > 33 ? '${value.substring(0, 30)}...' : value;
    print('${k.padRight(45)} $v');
  });
  print('─' * 80);
  print('Total: ${translations.length} keys\n');
}