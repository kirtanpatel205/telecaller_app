import 'dart:convert';
import 'dart:io';

// ══════════════════════════════════════════════════════════════
//  CONFIG
// ══════════════════════════════════════════════════════════════
const String androidPackage = 'com.digibulkmarketing.telecaller_app';
const String iosBundleId    = 'com.digibulkmarketing.telecallerApp';
const String macBundleId    = 'com.digibulkmarketing.telecallerApp';
const String windowsAppName = 'telecaller_app';
const String webAppName     = 'telecaller_app';
const String newAppName     = 'Telecaller';
const String dartPackName   = 'telecaller_app';
// ══════════════════════════════════════════════════════════════

final String sep = Platform.pathSeparator;

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

void ok(String msg)   => print('   ✅ $msg');
void warn(String msg) => print('   ⚠️  $msg');
void info(String msg) => print('   ℹ️  $msg');

void step(String title) {
  print('\n╔══════════════════════════════════════════════╗');
  print('║  📝 $title');
  print('╚══════════════════════════════════════════════╝');
}

// ── IMPORTANT: Only skip these specific dirs ──
final _skipDirs = {
  '.dart_tool', '.git', '.symlinks',
  '.plugin_symlinks', 'Pods', 'node_modules',
  // NOTE: Do NOT skip 'build' or '.gradle' — gradle is inside android folder
};

bool _shouldSkip(String path) {
  // Only skip if path segment exactly matches skip list
  final parts = path.split(sep);
  for (final part in parts) {
    if (_skipDirs.contains(part)) return true;
  }
  // Skip flutter internal build output only
  if (path.contains('${sep}build${sep}app${sep}')) return true;
  if (path.contains('${sep}build${sep}ios${sep}')) return true;
  if (path.contains('${sep}build${sep}windows${sep}')) return true;
  if (path.contains('${sep}build${sep}web${sep}')) return true;
  if (path.contains('${sep}build${sep}macos${sep}')) return true;
  if (path.contains('${sep}build${sep}linux${sep}')) return true;
  return false;
}

Future<List<File>> findFiles(String filename) async {
  final found = <File>[];
  try {
    for (final f in Directory.current.listSync(recursive: true).whereType<File>()) {
      if (_shouldSkip(f.path)) continue;
      if (f.path.split(sep).last == filename) found.add(f);
    }
  } catch (_) {}
  return found;
}

Future<List<File>> findFilesByExt(String ext, String inDir) async {
  final found = <File>[];
  final dir = Directory(inDir);
  if (!dir.existsSync()) return found;
  try {
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      if (_shouldSkip(f.path)) continue;
      if (f.path.endsWith(ext)) found.add(f);
    }
  } catch (_) {}
  return found;
}

// ══════════════════════════════════════════════════════════════
//  ANDROID
// ══════════════════════════════════════════════════════════════

// ── A1. build.gradle ──────────────────────────────────────────
Future<void> a1_buildGradle() async {
  step('ANDROID 1/5 — build.gradle');

  // Direct path first — most reliable
  final directPaths = [
    'android${sep}app${sep}build.gradle',
    'android${sep}app${sep}build.gradle.kts',
    'android/app/build.gradle',
    'android/app/build.gradle.kts',
  ];

  File? gradleFile;

  // Try direct paths first
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) {
      gradleFile = f;
      print('   📄 ${f.path}');
      break;
    }
  }

  // If not found, scan android folder only
  if (gradleFile == null) {
    final androidDir = Directory('android');
    if (androidDir.existsSync()) {
      for (final f in androidDir.listSync(recursive: true).whereType<File>()) {
        final name = f.path.split(sep).last;
        if (name == 'build.gradle' || name == 'build.gradle.kts') {
          try {
            final c = await f.readAsString();
            if (c.contains('applicationId')) {
              gradleFile = f;
              print('   📄 ${f.path}');
              break;
            }
          } catch (_) {}
        }
      }
    }
  }

  if (gradleFile == null) {
    warn('build.gradle not found in android/ folder!');
    // Show android folder contents for debug
    final androidDir = Directory('android');
    if (androidDir.existsSync()) {
      print('   📋 android/ contents:');
      androidDir.listSync(recursive: true).forEach((f) => print('      ${f.path}'));
    } else {
      warn('android/ directory does not exist!');
    }
    return;
  }

  String c = await gradleFile.readAsString();
  final kts = gradleFile.path.endsWith('.kts');
  bool changed = false;

  // namespace
  final nsRx = [
    RegExp(r'namespace\s*=\s*"[a-zA-Z0-9_.]+"'),
    RegExp(r"namespace\s*=\s*'[a-zA-Z0-9_.]+'"),
    RegExp(r'namespace\s+"[a-zA-Z0-9_.]+"'),
    RegExp(r"namespace\s+'[a-zA-Z0-9_.]+'"),
  ];
  bool nsDone = false;
  for (final rx in nsRx) {
    if (rx.hasMatch(c)) {
      c = c.replaceAll(rx, 'namespace = "$androidPackage"');
      ok('namespace updated'); changed = true; nsDone = true; break;
    }
  }
  if (!nsDone) {
    final ab = RegExp(r'android\s*\{');
    if (ab.hasMatch(c)) {
      c = c.replaceFirst(ab, 'android {\n    namespace = "$androidPackage"');
      ok('namespace injected'); changed = true;
    }
  }

  // applicationId
  final aiRx = [
    RegExp(r'applicationId\s*=\s*"[a-zA-Z0-9_.]+"'),
    RegExp(r"applicationId\s*=\s*'[a-zA-Z0-9_.]+'"),
    RegExp(r'applicationId\s+"[a-zA-Z0-9_.]+"'),
    RegExp(r"applicationId\s+'[a-zA-Z0-9_.]+'"),
  ];
  for (final rx in aiRx) {
    if (rx.hasMatch(c)) {
      c = c.replaceAll(rx, kts
          ? 'applicationId = "$androidPackage"'
          : 'applicationId "$androidPackage"');
      ok('applicationId updated'); changed = true; break;
    }
  }

  if (changed) {
    await gradleFile.writeAsString(c);
    ok('Saved → ${gradleFile.path}');
  } else {
    warn('No patterns matched! File content:');
    print(c.substring(0, c.length > 800 ? 800 : c.length));
  }
}

// ── A2. AndroidManifest.xml ───────────────────────────────────
Future<void> a2_manifests() async {
  step('ANDROID 2/5 — AndroidManifest.xml');
  final files = await findFiles('AndroidManifest.xml');
  if (files.isEmpty) { warn('No AndroidManifest.xml found!'); return; }

  for (final file in files) {
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final pkgRx = RegExp(r'package="[a-zA-Z0-9_.]+"');
    if (pkgRx.hasMatch(c)) {
      c = c.replaceAll(pkgRx, 'package="$androidPackage"');
      changed = true; ok('package= updated');
    }

    final labelRx = RegExp(r'android:label="[^"]*"');
    if (labelRx.hasMatch(c)) {
      c = c.replaceAll(labelRx, 'android:label="$newAppName"');
      changed = true; ok('android:label updated');
    }

    final fqn = RegExp(r'android:name="([a-zA-Z0-9_.]+)\.([A-Z][a-zA-Z0-9_]*)"');
    if (fqn.hasMatch(c)) {
      c = c.replaceAllMapped(fqn, (m) => 'android:name="$androidPackage.${m.group(2)}"');
      changed = true; ok('FQN class names updated');
    }

    final authRx = RegExp(r'android:authorities="[a-zA-Z0-9_.]+"');
    if (authRx.hasMatch(c)) {
      c = c.replaceAll(authRx, 'android:authorities="$androidPackage"');
      changed = true; ok('authorities updated');
    }

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

// ── A3. google-services.json ──────────────────────────────────
Future<void> a3_googleServices() async {
  step('ANDROID 3/5 — google-services.json');

  // Direct path
  final directPaths = [
    'android${sep}app${sep}google-services.json',
    'android/app/google-services.json',
  ];

  File? gsFile;
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) { gsFile = f; break; }
  }

  // Scan android folder
  if (gsFile == null) {
    final androidDir = Directory('android');
    if (androidDir.existsSync()) {
      for (final f in androidDir.listSync(recursive: true).whereType<File>()) {
        if (f.path.split(sep).last == 'google-services.json') { gsFile = f; break; }
      }
    }
  }

  if (gsFile == null) {
    warn('google-services.json not found');
    info('Place google-services.json in android/app/ from Firebase Console');
    return;
  }

  print('   📄 ${gsFile.path}');
  try {
    final Map<String, dynamic> json = jsonDecode(await gsFile.readAsString());

    void replace(dynamic node) {
      if (node is Map) {
        node.forEach((k, v) {
          if (k == 'package_name' && v is String) {
            ok('package_name: $v → $androidPackage');
            node[k] = androidPackage;
          } else replace(v);
        });
      } else if (node is List) {
        for (final i in node) replace(i);
      }
    }

    replace(json);
    await gsFile.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    ok('Saved');
  } catch (e) {
    warn('Error parsing google-services.json: $e');
  }
}

// ── A4. Kotlin/Java source ────────────────────────────────────
Future<void> a4_kotlinJava() async {
  step('ANDROID 4/5 — Kotlin/Java source files');

  Directory? baseDir;
  String ext = '.kt';

  // Direct paths
  final kotlinPath = 'android${sep}app${sep}src${sep}main${sep}kotlin';
  final javaPath   = 'android${sep}app${sep}src${sep}main${sep}java';

  if (Directory(kotlinPath).existsSync()) {
    baseDir = Directory(kotlinPath); ext = '.kt';
    print('   📁 $kotlinPath');
  } else if (Directory(javaPath).existsSync()) {
    baseDir = Directory(javaPath); ext = '.java';
    print('   📁 $javaPath');
  } else {
    // Scan
    for (final dir in Directory.current.listSync(recursive: true).whereType<Directory>()) {
      final p = dir.path;
      if (_shouldSkip(p)) continue;
      if ((p.endsWith('kotlin') || p.endsWith('java')) &&
          (p.contains('src${sep}main') || p.contains('src/main'))) {
        baseDir = dir; ext = p.endsWith('kotlin') ? '.kt' : '.java';
        print('   📁 $p'); break;
      }
    }
  }

  if (baseDir == null) { warn('No kotlin/java source dir found'); return; }

  final allFiles = baseDir.listSync(recursive: true).whereType<File>()
      .where((f) => f.path.endsWith(ext)).toList();
  if (allFiles.isEmpty) { warn('No $ext files found'); return; }

  // Detect old package
  String oldPkg = '';
  for (final f in allFiles) {
    final m = RegExp(r'^package\s+([a-zA-Z0-9_.]+)', multiLine: true)
        .firstMatch(await f.readAsString());
    if (m != null) { oldPkg = m.group(1)!; break; }
  }

  print('   Old: $oldPkg');
  print('   New: $androidPackage');

  // Rename folder if needed
  if (oldPkg.isNotEmpty && oldPkg != androidPackage) {
    final oldPath = '${baseDir.path}$sep${oldPkg.replaceAll('.', sep)}';
    final newPath = '${baseDir.path}$sep${androidPackage.replaceAll('.', sep)}';
    final oldDir  = Directory(oldPath);

    if (oldDir.existsSync() && oldPath != newPath) {
      Directory(newPath).createSync(recursive: true);
      for (final src in oldDir.listSync(recursive: true).whereType<File>()) {
        final rel  = src.path.substring(oldPath.length);
        final dest = newPath + rel;
        Directory(dest.substring(0, dest.lastIndexOf(sep))).createSync(recursive: true);
        await src.copy(dest);
        ok('Moved: ${src.path.split(sep).last}');
      }
      oldDir.deleteSync(recursive: true);
      ok('Folder renamed');
    } else info('Folder already correct or not found');
  } else info('Folder already correct');

  // Update declarations in all files
  for (final f in baseDir.listSync(recursive: true).whereType<File>()
      .where((f) => f.path.endsWith(ext))) {
    String c = await f.readAsString();
    bool changed = false;

    final pkgRx = RegExp(r'^package\s+[a-zA-Z0-9_.]+', multiLine: true);
    if (pkgRx.hasMatch(c)) {
      c = c.replaceAll(pkgRx, 'package $androidPackage');
      changed = true;
    }
    if (oldPkg.isNotEmpty && c.contains('import $oldPkg.')) {
      c = c.replaceAll('import $oldPkg.', 'import $androidPackage.');
      changed = true;
    }
    if (changed) {
      await f.writeAsString(c);
      ok('Updated: ${f.path.split(sep).last}');
    }
  }
}

// ── A5. strings.xml ───────────────────────────────────────────
Future<void> a5_stringsXml() async {
  step('ANDROID 5/5 — strings.xml');

  // Direct paths
  final directPaths = [
    'android${sep}app${sep}src${sep}main${sep}res${sep}values${sep}strings.xml',
    'android/app/src/main/res/values/strings.xml',
  ];

  File? strFile;
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) { strFile = f; break; }
  }

  if (strFile == null) {
    // strings.xml does not exist — CREATE it
    final createPath = 'android${sep}app${sep}src${sep}main${sep}res${sep}values${sep}strings.xml';
    final dir = Directory(createPath.substring(0, createPath.lastIndexOf(sep)));
    dir.createSync(recursive: true);
    strFile = File(createPath);
    await strFile.writeAsString('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$newAppName</string>
</resources>''');
    ok('strings.xml created with app_name → $newAppName');
    return;
  }

  print('   📄 ${strFile.path}');
  String c = await strFile.readAsString();
  final rx = RegExp(r'<string name="app_name">[^<]*<\/string>');
  if (rx.hasMatch(c)) {
    c = c.replaceAll(rx, '<string name="app_name">$newAppName</string>');
    await strFile.writeAsString(c);
    ok('app_name → $newAppName');
  } else {
    // Inject into resources
    c = c.replaceFirst('</resources>', '    <string name="app_name">$newAppName</string>\n</resources>');
    await strFile.writeAsString(c);
    ok('app_name injected → $newAppName');
  }
}

// ══════════════════════════════════════════════════════════════
//  iOS
// ══════════════════════════════════════════════════════════════

Future<void> i1_infoPlist() async {
  step('iOS 1/4 — Info.plist');
  final files = await findFiles('Info.plist');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    if (file.path.contains('macos') || file.path.contains('MacOS')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    void replacePlist(String key, String val) {
      final rx = RegExp('(<key>$key<\\/key>\\s*<string>)[^<]*(<\\/string>)', dotAll: true);
      if (rx.hasMatch(c)) {
        c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$val${m.group(2)}');
        changed = true; ok('$key → $val');
      }
    }

    replacePlist('CFBundleIdentifier', iosBundleId);
    replacePlist('CFBundleName', newAppName);
    replacePlist('CFBundleDisplayName', newAppName);

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

Future<void> i2_pbxproj() async {
  step('iOS 2/4 — project.pbxproj');
  final files = await findFiles('project.pbxproj');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    if (file.path.contains('macos') || file.path.contains('MacOS')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final bidRx = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[a-zA-Z0-9_.]+\s*;');
    if (bidRx.hasMatch(c)) {
      c = c.replaceAll(bidRx, 'PRODUCT_BUNDLE_IDENTIFIER = $iosBundleId;');
      changed = true; ok('PRODUCT_BUNDLE_IDENTIFIER → $iosBundleId');
    }

    final nameRx = RegExp(r'PRODUCT_NAME\s*=\s*"?[^";]+"?\s*;');
    if (nameRx.hasMatch(c)) {
      c = c.replaceAll(nameRx, 'PRODUCT_NAME = "$newAppName";');
      changed = true; ok('PRODUCT_NAME → $newAppName');
    }

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

Future<void> i3_googleServiceInfo() async {
  step('iOS 3/4 — GoogleService-Info.plist');
  final files = await findFiles('GoogleService-Info.plist');
  if (files.isEmpty) {
    warn('Not found');
    info('Download from Firebase Console → Project Settings → iOS app');
    return;
  }

  for (final file in files) {
    if (file.path.contains('macos')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    final rx = RegExp(r'(<key>BUNDLE_ID<\/key>\s*<string>)[^<]*(<\/string>)', dotAll: true);
    if (rx.hasMatch(c)) {
      c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$iosBundleId${m.group(2)}');
      await file.writeAsString(c);
      ok('BUNDLE_ID → $iosBundleId');
    } else info('BUNDLE_ID not found');
  }
}

Future<void> i4_podfile() async {
  step('iOS 4/4 — Podfile');

  // Direct path
  final f = File('ios${sep}Podfile');
  final f2 = File('ios/Podfile');
  final podFile = f.existsSync() ? f : (f2.existsSync() ? f2 : null);

  if (podFile == null) { info('Podfile not found (normal if not run on Mac)'); return; }

  print('   📄 ${podFile.path}');
  String c = await podFile.readAsString();
  final rx = RegExp(r"bundle_identifier\s*=\s*'[a-zA-Z0-9_.]+'");
  if (rx.hasMatch(c)) {
    c = c.replaceAll(rx, "bundle_identifier = '$iosBundleId'");
    await podFile.writeAsString(c);
    ok('bundle_identifier → $iosBundleId');
  } else info('No bundle_identifier in Podfile (normal)');
}

// ══════════════════════════════════════════════════════════════
//  macOS
// ══════════════════════════════════════════════════════════════

Future<void> m1_macInfoPlist() async {
  step('macOS 1/2 — Info.plist');
  final files = await findFiles('Info.plist');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    if (!file.path.contains('macos') && !file.path.contains('MacOS')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    void replacePlist(String key, String val) {
      final rx = RegExp('(<key>$key<\\/key>\\s*<string>)[^<]*(<\\/string>)', dotAll: true);
      if (rx.hasMatch(c)) {
        c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$val${m.group(2)}');
        changed = true; ok('$key → $val');
      }
    }

    replacePlist('CFBundleIdentifier', macBundleId);
    replacePlist('CFBundleName', newAppName);
    replacePlist('CFBundleDisplayName', newAppName);

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

Future<void> m2_macPbxproj() async {
  step('macOS 2/2 — project.pbxproj');
  final files = await findFiles('project.pbxproj');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    if (!file.path.contains('macos') && !file.path.contains('MacOS')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final bidRx = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[a-zA-Z0-9_.]+\s*;');
    if (bidRx.hasMatch(c)) {
      c = c.replaceAll(bidRx, 'PRODUCT_BUNDLE_IDENTIFIER = $macBundleId;');
      changed = true; ok('PRODUCT_BUNDLE_IDENTIFIER → $macBundleId');
    }

    final nameRx = RegExp(r'PRODUCT_NAME\s*=\s*"?[^";]+"?\s*;');
    if (nameRx.hasMatch(c)) {
      c = c.replaceAll(nameRx, 'PRODUCT_NAME = "$newAppName";');
      changed = true; ok('PRODUCT_NAME → $newAppName');
    }

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

// ══════════════════════════════════════════════════════════════
//  WINDOWS
// ══════════════════════════════════════════════════════════════

Future<void> w1_cmakeLists() async {
  step('WINDOWS 1/3 — CMakeLists.txt');
  final files = await findFiles('CMakeLists.txt');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    if (!file.path.contains('windows')) continue;
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final projRx = RegExp(r'project\s*\(\s*[a-zA-Z0-9_\s"]+\s*\)');
    if (projRx.hasMatch(c)) {
      c = c.replaceAll(projRx, 'project($windowsAppName)');
      changed = true; ok('project → $windowsAppName');
    }

    final binRx = RegExp(r'set\s*\(\s*BINARY_NAME\s+"?[a-zA-Z0-9_]+"?\s*\)');
    if (binRx.hasMatch(c)) {
      c = c.replaceAll(binRx, 'set(BINARY_NAME "$windowsAppName")');
      changed = true; ok('BINARY_NAME → $windowsAppName');
    }

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

Future<void> w2_runnerRc() async {
  step('WINDOWS 2/3 — Runner.rc');
  final files = await findFiles('Runner.rc');
  if (files.isEmpty) { warn('Not found'); return; }

  for (final file in files) {
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final Map<RegExp, String> replacements = {
      RegExp(r'VALUE\s+"FileDescription",\s*"[^"]*"'): 'VALUE "FileDescription", "$newAppName"',
      RegExp(r'VALUE\s+"ProductName",\s*"[^"]*"'):     'VALUE "ProductName", "$newAppName"',
      RegExp(r'VALUE\s+"InternalName",\s*"[^"]*"'):    'VALUE "InternalName", "$windowsAppName"',
      RegExp(r'VALUE\s+"OriginalFilename",\s*"[^"]*"'): 'VALUE "OriginalFilename", "$windowsAppName.exe"',
    };

    replacements.forEach((rx, replacement) {
      if (rx.hasMatch(c)) { c = c.replaceAll(rx, replacement); changed = true; ok(replacement); }
    });

    if (changed) await file.writeAsString(c);
    else info('Nothing to change');
  }
}

Future<void> w3_mainCpp() async {
  step('WINDOWS 3/3 — win32_window.cpp (Window title)');

  // Direct path for win32_window.cpp
  final targetFile = File('windows${sep}runner${sep}win32_window.cpp');
  final targetFile2 = File('windows/runner/win32_window.cpp');
  final winFile = targetFile.existsSync() ? targetFile : (targetFile2.existsSync() ? targetFile2 : null);

  if (winFile == null) {
    warn('win32_window.cpp not found');
    return;
  }

  print('   📄 ${winFile.path}');
  String c = await winFile.readAsString();

  // GetWindowTitle or window title string
  // Flutter default: L"telecaller_app" or L"old_name"
  final titleRx = RegExp(r'L"[^"\\]+"');
  bool changed = false;

  if (titleRx.hasMatch(c)) {
    c = c.replaceAllMapped(titleRx, (m) {
      final val = m.group(0)!;
      // Only replace if looks like app name (not a path or system string)
      if (!val.contains('\\') && !val.contains('/') && !val.contains('.')) {
        changed = true;
        return 'L"$newAppName"';
      }
      return val;
    });
    if (changed) { await winFile.writeAsString(c); ok('Window title → $newAppName'); }
    else info('No replaceable title found');
  } else info('No L"..." strings found');
}

// ══════════════════════════════════════════════════════════════
//  WEB
// ══════════════════════════════════════════════════════════════

Future<void> web1_indexHtml() async {
  step('WEB 1/2 — index.html');

  final f  = File('web${sep}index.html');
  final f2 = File('web/index.html');
  final webFile = f.existsSync() ? f : (f2.existsSync() ? f2 : null);

  if (webFile == null) { warn('web/index.html not found'); return; }
  print('   📄 ${webFile.path}');

  String c = await webFile.readAsString();
  bool changed = false;

  final titleRx = RegExp(r'<title>[^<]*<\/title>');
  if (titleRx.hasMatch(c)) {
    c = c.replaceAll(titleRx, '<title>$newAppName</title>');
    changed = true; ok('<title> → $newAppName');
  }

  final descRx = RegExp(r'(<meta\s+name="description"\s+content=")[^"]*(")', dotAll: true);
  if (descRx.hasMatch(c)) {
    c = c.replaceAllMapped(descRx, (m) => '${m.group(1)}$newAppName${m.group(2)}');
    changed = true; ok('meta description → $newAppName');
  }

  final appleRx = RegExp(r'(<meta\s+name="apple-mobile-web-app-title"\s+content=")[^"]*(")', dotAll: true);
  if (appleRx.hasMatch(c)) {
    c = c.replaceAllMapped(appleRx, (m) => '${m.group(1)}$newAppName${m.group(2)}');
    changed = true; ok('apple-mobile-web-app-title → $newAppName');
  }

  if (changed) await webFile.writeAsString(c);
  else info('Nothing to change');
}

Future<void> web2_manifest() async {
  step('WEB 2/2 — manifest.json');

  final f  = File('web${sep}manifest.json');
  final f2 = File('web/manifest.json');
  final mFile = f.existsSync() ? f : (f2.existsSync() ? f2 : null);

  if (mFile == null) { warn('web/manifest.json not found'); return; }
  print('   📄 ${mFile.path}');

  final Map<String, dynamic> json = jsonDecode(await mFile.readAsString());
  if (json.containsKey('name'))       { json['name'] = newAppName;  ok('name → $newAppName'); }
  if (json.containsKey('short_name')) { json['short_name'] = newAppName; ok('short_name → $newAppName'); }
  if (json.containsKey('id'))         { json['id'] = webAppName;    ok('id → $webAppName'); }

  await mFile.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  ok('Saved');
}

// ══════════════════════════════════════════════════════════════
//  COMMON
// ══════════════════════════════════════════════════════════════

Future<void> c1_pubspec() async {
  step('COMMON 1/2 — pubspec.yaml');
  final f = File('pubspec.yaml');
  if (!f.existsSync()) { warn('pubspec.yaml not found'); return; }

  print('   📄 ${f.path}');
  final lines   = await f.readAsLines();
  final updated = lines.map((l) => l.trim().startsWith('name:') ? 'name: $dartPackName' : l).toList();
  await f.writeAsString(updated.join('\n'));
  ok('name → $dartPackName');
}

// Future<void> c2_dartImports() async {
//   step('COMMON 2/2 — Dart imports in lib/');
//
//   final libDir = Directory('lib');
//   if (!libDir.existsSync()) { warn('lib/ not found'); return; }
//   print('   📁 ${libDir.path}');
//
//   final dartFiles = libDir.listSync(recursive: true).whereType<File>()
//       .where((f) => f.path.endsWith('.dart')).toList();
//
//   // Read OLD name from pubspec BEFORE change
//   // Actually read from existing imports — skip ALL known pub packages
//   // Use a comprehensive skip list
//   const skipPkgs = {
//     'flutter', 'get', 'getx', 'dio', 'http', 'provider', 'bloc', 'flutter_bloc',
//     'rxdart', 'hive', 'hive_flutter', 'sqflite', 'drift',
//     'firebase_core', 'firebase_auth', 'firebase_messaging', 'firebase_analytics',
//     'firebase_storage', 'firebase_database', 'firebase_crashlytics',
//     'cloud_firestore', 'shared_preferences', 'path_provider', 'path',
//     'image_picker', 'cached_network_image', 'intl', 'url_launcher',
//     'google_sign_in', 'flutter_local_notifications', 'connectivity_plus',
//     'permission_handler', 'lottie', 'shimmer', 'fluttertoast',
//     'awesome_notifications', 'flutter_screenutil', 'flutter_svg',
//     'pin_code_fields', 'local_auth', 'equatable', 'freezed',
//     'json_annotation', 'retrofit', 'logger', 'dartz', 'injectable',
//     'get_it', 'auto_route', 'go_router', 'flex_color_scheme',
//     'flutter_launcher_icons', 'google_fonts', 'animations', 'fl_chart',
//     'image_cropper', 'video_player', 'webview_flutter', 'in_app_purchase',
//     'purchases_flutter', 'onesignal_flutter', 'mixpanel_flutter',
//     'flutter_animate', 'rive', 'skeletonizer', 'pull_to_refresh',
//     'infinite_scroll_pagination', 'flutter_easyloading', 'overlay_support',
//     'flutterfire_ui', 'cloud_functions', 'supabase_flutter',
//     'appwrite', 'pocketbase', 'isar', 'objectbox', 'realm',
//     'table_calendar', 'syncfusion_flutter_charts', 'data_table_2',
//     'pluto_grid', 'flutter_quill', 'rich_text_controller',
//     'encrypt', 'crypto', 'uuid', 'nanoid', 'ulid',
//     'dart_vlc', 'just_audio', 'audioplayers', 'record',
//     'camera', 'qr_code_scanner', 'mobile_scanner', 'barcode_widget',
//     'geolocator', 'google_maps_flutter', 'mapbox_gl', 'flutter_map',
//     'contacts_service', 'call_log', 'phone_state', 'sim_card_info',
//     'flutter_phone_direct_caller', 'direct_caller', 'phone_number',
//     'country_code_picker', 'flag', 'currency_picker',
//     'file_picker', 'open_file', 'document_scanner',
//     'pdf', 'printing', 'pdf_render', 'syncfusion_flutter_pdf',
//     'excel', 'spreadsheet_decoder', 'csv',
//     'socket_io_client', 'web_socket_channel', 'stomp_dart_client',
//     'agora_rtc_engine', 'zego_uikit', 'livekit_client',
//     'twilio_voice', 'flutter_callkit_incoming',
//     'sentry_flutter', 'datadog_flutter_plugin', 'instabug_flutter',
//     'appsflyer_sdk', 'adjust_sdk', 'amplitude_flutter',
//     'flutter_facebook_auth', 'twitter_login', 'linkedin_login',
//     'sign_in_with_apple', 'flutter_native_splash', 'introduction_screen',
//     'onboarding', 'smooth_page_indicator', 'dots_indicator',
//     'animated_bottom_navigation_bar', 'curved_navigation_bar',
//     'persistent_bottom_nav_bar', 'bottom_navy_bar',
//     'flutter_speed_dial', 'fab_circular_menu', 'expandable_fab',
//     'badges', 'flutter_badge', 'unicons', 'font_awesome_flutter',
//     'iconsax', 'hugeicons', 'phosphor_flutter',
//     'flutter_slidable', 'flutter_dismissible_page',
//     'reorderable_grid_view', 'drag_and_drop_lists',
//     'signature', 'hand_signature', 'flutter_drawing_board',
//     'colorful_safe_area', 'glass_kit', 'glassmorphism',
//     'neumorphic_flutter', 'clay_containers', 'concave_decoration',
//   };
//
//   // Find old dart package name — must match project name pattern
//   String oldName = '';
//   for (final file in dartFiles) {
//     String content;
//     try { content = await file.readAsString(); } catch (_) { continue; }
//
//     for (final m in RegExp(r"import 'package:([a-zA-Z0-9_]+)/").allMatches(content)) {
//       final n = m.group(1)!;
//       // Must not be in skip list AND must look like a project name
//       // (contains underscore or matches simple word pattern, not a lib name)
//       if (!skipPkgs.contains(n) && n != dartPackName) {
//         oldName = n;
//         print('   Detected old dart name: $oldName (from ${file.path})');
//         break;
//       }
//     }
//     if (oldName.isNotEmpty) break;
//   }
//
//   if (oldName.isEmpty) {
//     info('Could not detect old dart package name — checking pubspec.yaml backup');
//
//     // Read from pubspec as fallback — read CURRENT name before we changed it
//     // Since we already changed pubspec, try to find from import patterns differently
//     info('Skipping dart import update — already correct or could not detect');
//     return;
//   }
//
//   if (oldName == dartPackName) {
//     info('Dart imports already correct ($dartPackName)');
//     return;
//   }
//
//   print('   Old: $oldName  →  New: $dartPackName');
//
//   int count = 0;
//   for (final file in dartFiles) {
//     String c;
//     try { c = await file.readAsString(); } catch (_) { continue; }
//
//     if (c.contains("package:$oldName/")) {
//       await file.writeAsString(c.replaceAll("package:$oldName/", "package:$dartPackName/"));
//       count++;
//       ok(file.path.replaceFirst(Directory.current.path, ''));
//     }
//   }
//   ok('$count files updated');
// }

// ══════════════════════════════════════════════════════════════
//  MAIN
// ══════════════════════════════════════════════════════════════

Future<void> main() async {
  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║    FULL PROJECT REBRAND — Android+iOS+macOS+Windows+Web     ║');
  print('║    Pure Dart — Zero External Packages — All Bugs Fixed      ║');
  print('╠══════════════════════════════════════════════════════════════╣');
  print('║  Android : $androidPackage');
  print('║  iOS     : $iosBundleId');
  print('║  macOS   : $macBundleId');
  print('║  Windows : $windowsAppName');
  print('║  Web     : $webAppName');
  print('║  AppName : $newAppName');
  print('║  Root    : ${Directory.current.path}');
  print('╚══════════════════════════════════════════════════════════════╝');

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ANDROID  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await a1_buildGradle();
  await a2_manifests();
  await a3_googleServices();
  await a4_kotlinJava();
  await a5_stringsXml();

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  iOS  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await i1_infoPlist();
  await i2_pbxproj();
  await i3_googleServiceInfo();
  await i4_podfile();

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  macOS  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await m1_macInfoPlist();
  await m2_macPbxproj();

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  WINDOWS  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await w1_cmakeLists();
  await w2_runnerRc();
  await w3_mainCpp();

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  WEB  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await web1_indexHtml();
  await web2_manifest();

  print('\n\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  COMMON  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓');
  await c1_pubspec();
  // await c2_dartImports();

  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║  🎉 ALL DONE — બધા platforms સંપૂર્ણ બદલાઈ ગયા!             ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');
  print('👉 હવે આ run કરો:');
  print('   flutter clean');
  print('   flutter pub get');
  print('   cd ios && pod install && cd ..');
  print('   flutter run');
  print('');
  print('⚠️  build.gradle હજુ fix ન થયો હોય તો:');
  print('   android/app/build.gradle manually check કરો');
  print('   applicationId "$androidPackage" છે કે નહીં');
  print('');
}