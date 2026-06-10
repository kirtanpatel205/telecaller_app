import 'dart:convert';
import 'dart:io';

final String sep = Platform.pathSeparator;

// ══════════════════════════════════════════════════════════════
//  DYNAMIC CONFIGURATION
// ══════════════════════════════════════════════════════════════
late String androidPackage;
late String iosBundleId;
late String macBundleId;
late String windowsAppName;
late String webAppName;
late String newAppName;
late String dartPackName;
late String firebaseProjectId;
late String firebaseAppId;
late String appIconPath;

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

final _skipDirs = {
  '.dart_tool', '.git', '.symlinks',
  '.plugin_symlinks', 'Pods', 'node_modules',
};

bool _shouldSkip(String path) {
  final parts = path.split(sep);
  for (final part in parts) {
    if (_skipDirs.contains(part)) return true;
  }
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

// ══════════════════════════════════════════════════════════════
//  ANDROID
// ══════════════════════════════════════════════════════════════

Future<void> a1_buildGradle() async {
  step('ANDROID 1/5 — build.gradle');
  final directPaths = [
    'android${sep}app${sep}build.gradle',
    'android${sep}app${sep}build.gradle.kts',
    'android/app/build.gradle',
    'android/app/build.gradle.kts',
  ];

  File? gradleFile;
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) { gradleFile = f; print('   📄 ${f.path}'); break; }
  }

  if (gradleFile == null) {
    final androidDir = Directory('android');
    if (androidDir.existsSync()) {
      for (final f in androidDir.listSync(recursive: true).whereType<File>()) {
        final name = f.path.split(sep).last;
        if (name == 'build.gradle' || name == 'build.gradle.kts') {
          try {
            final c = await f.readAsString();
            if (c.contains('applicationId')) { gradleFile = f; print('   📄 ${f.path}'); break; }
          } catch (_) {}
        }
      }
    }
  }

  if (gradleFile == null) { warn('build.gradle not found in android/ folder!'); return; }

  String c = await gradleFile.readAsString();
  final kts = gradleFile.path.endsWith('.kts');
  bool changed = false;

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

  final aiRx = [
    RegExp(r'applicationId\s*=\s*"[a-zA-Z0-9_.]+"'),
    RegExp(r"applicationId\s*=\s*'[a-zA-Z0-9_.]+'"),
    RegExp(r'applicationId\s+"[a-zA-Z0-9_.]+"'),
    RegExp(r"applicationId\s+'[a-zA-Z0-9_.]+'"),
  ];
  for (final rx in aiRx) {
    if (rx.hasMatch(c)) {
      c = c.replaceAll(rx, kts ? 'applicationId = "$androidPackage"' : 'applicationId "$androidPackage"');
      ok('applicationId updated'); changed = true; break;
    }
  }

  if (changed) { await gradleFile.writeAsString(c); ok('Saved → ${gradleFile.path}'); }
  else { warn('No patterns matched!'); }
}

Future<void> a2_manifests() async {
  step('ANDROID 2/5 — AndroidManifest.xml');
  final files = await findFiles('AndroidManifest.xml');
  if (files.isEmpty) { warn('No AndroidManifest.xml found!'); return; }

  for (final file in files) {
    print('   📄 ${file.path}');
    String c = await file.readAsString();
    bool changed = false;

    final pkgRx = RegExp(r'package="[a-zA-Z0-9_.]+"');
    if (pkgRx.hasMatch(c)) { c = c.replaceAll(pkgRx, 'package="$androidPackage"'); changed = true; ok('package= updated'); }

    final labelRx = RegExp(r'android:label="[^"]*"');
    if (labelRx.hasMatch(c)) { c = c.replaceAll(labelRx, 'android:label="$newAppName"'); changed = true; ok('android:label updated'); }

    final fqn = RegExp(r'android:name="([a-zA-Z0-9_.]+)\.([A-Z][a-zA-Z0-9_]*)"');
    if (fqn.hasMatch(c)) { c = c.replaceAllMapped(fqn, (m) => 'android:name="$androidPackage.${m.group(2)}"'); changed = true; ok('FQN class names updated'); }

    final authRx = RegExp(r'android:authorities="[a-zA-Z0-9_.]+"');
    if (authRx.hasMatch(c)) { c = c.replaceAll(authRx, 'android:authorities="$androidPackage"'); changed = true; ok('authorities updated'); }

    if (changed) await file.writeAsString(c);
  }
}

Future<void> a3_googleServices() async {
  step('ANDROID 3/5 — google-services.json');
  final directPaths = ['android${sep}app${sep}google-services.json', 'android/app/google-services.json'];
  File? gsFile;
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) { gsFile = f; break; }
  }

  if (gsFile == null) { warn('google-services.json not found'); return; }
  print('   📄 ${gsFile.path}');
  try {
    final Map<String, dynamic> json = jsonDecode(await gsFile.readAsString());
    void replace(dynamic node) {
      if (node is Map) {
        node.forEach((k, v) {
          if (k == 'package_name' && v is String) { node[k] = androidPackage; } else replace(v);
        });
      } else if (node is List) { for (final i in node) replace(i); }
    }
    replace(json);
    await gsFile.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    ok('Saved with updated package');
  } catch (e) { warn('Error parsing google-services.json: $e'); }
}

Future<void> a4_kotlinJava() async {
  step('ANDROID 4/5 — Kotlin/Java source files');
  Directory? baseDir;
  String ext = '.kt';
  final kotlinPath = 'android${sep}app${sep}src${sep}main${sep}kotlin';
  final javaPath   = 'android${sep}app${sep}src${sep}main${sep}java';

  if (Directory(kotlinPath).existsSync()) { baseDir = Directory(kotlinPath); ext = '.kt'; }
  else if (Directory(javaPath).existsSync()) { baseDir = Directory(javaPath); ext = '.java'; }

  if (baseDir == null) { warn('No kotlin/java source dir found'); return; }
  final allFiles = baseDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith(ext)).toList();
  if (allFiles.isEmpty) { warn('No $ext files found'); return; }

  String oldPkg = '';
  for (final f in allFiles) {
    final m = RegExp(r'^package\s+([a-zA-Z0-9_.]+)', multiLine: true).firstMatch(await f.readAsString());
    if (m != null) { oldPkg = m.group(1)!; break; }
  }

  if (oldPkg.isNotEmpty && oldPkg != androidPackage) {
    final oldPath = '${baseDir.path}$sep${oldPkg.replaceAll('.', sep)}';
    final newPath = '${baseDir.path}$sep${androidPackage.replaceAll('.', sep)}';
    final oldDir  = Directory(oldPath);
    if (oldDir.existsSync() && oldPath != newPath) {
      Directory(newPath).createSync(recursive: true);
      for (final src in oldDir.listSync(recursive: true).whereType<File>()) {
        final rel = src.path.substring(oldPath.length);
        final dest = newPath + rel;
        Directory(dest.substring(0, dest.lastIndexOf(sep))).createSync(recursive: true);
        await src.copy(dest);
      }
      oldDir.deleteSync(recursive: true);
      ok('Folder renamed to match package');
    }
  }

  for (final f in baseDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith(ext))) {
    String c = await f.readAsString();
    bool changed = false;
    final pkgRx = RegExp(r'^package\s+[a-zA-Z0-9_.]+', multiLine: true);
    if (pkgRx.hasMatch(c)) { c = c.replaceAll(pkgRx, 'package $androidPackage'); changed = true; }
    if (oldPkg.isNotEmpty && c.contains('import $oldPkg.')) { c = c.replaceAll('import $oldPkg.', 'import $androidPackage.'); changed = true; }
    if (changed) { await f.writeAsString(c); ok('Updated: ${f.path.split(sep).last}'); }
  }
}

Future<void> a5_stringsXml() async {
  step('ANDROID 5/5 — strings.xml');
  final directPaths = ['android${sep}app${sep}src${sep}main${sep}res${sep}values${sep}strings.xml', 'android/app/src/main/res/values/strings.xml'];
  File? strFile;
  for (final path in directPaths) {
    final f = File(path);
    if (f.existsSync()) { strFile = f; break; }
  }

  if (strFile == null) {
    final createPath = 'android${sep}app${sep}src${sep}main${sep}res${sep}values${sep}strings.xml';
    Directory(createPath.substring(0, createPath.lastIndexOf(sep))).createSync(recursive: true);
    strFile = File(createPath);
    await strFile.writeAsString('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">$newAppName</string>\n</resources>');
    ok('strings.xml created');
    return;
  }
  String c = await strFile.readAsString();
  final rx = RegExp(r'<string name="app_name">[^<]*<\/string>');
  if (rx.hasMatch(c)) {
    c = c.replaceAll(rx, '<string name="app_name">$newAppName</string>');
    await strFile.writeAsString(c);
  } else {
    c = c.replaceFirst('</resources>', '    <string name="app_name">$newAppName</string>\n</resources>');
    await strFile.writeAsString(c);
  }
  ok('app_name set to $newAppName');
}

// ══════════════════════════════════════════════════════════════
//  iOS
// ══════════════════════════════════════════════════════════════

Future<void> i1_infoPlist() async {
  step('iOS 1/4 — Info.plist');
  final files = await findFiles('Info.plist');
  for (final file in files) {
    if (file.path.contains('macos') || file.path.contains('MacOS')) continue;
    String c = await file.readAsString();
    bool changed = false;
    void replacePlist(String key, String val) {
      final rx = RegExp('(<key>$key<\\/key>\\s*<string>)[^<]*(<\\/string>)', dotAll: true);
      if (rx.hasMatch(c)) { c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$val${m.group(2)}'); changed = true; }
    }
    replacePlist('CFBundleIdentifier', iosBundleId);
    replacePlist('CFBundleName', newAppName);
    replacePlist('CFBundleDisplayName', newAppName);
    if (changed) { await file.writeAsString(c); ok('Updated iOS Info.plist'); }
  }
}

Future<void> i2_pbxproj() async {
  step('iOS 2/4 — project.pbxproj');
  final files = await findFiles('project.pbxproj');
  for (final file in files) {
    if (file.path.contains('macos') || file.path.contains('MacOS')) continue;
    String c = await file.readAsString();
    bool changed = false;
    final bidRx = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[a-zA-Z0-9_.]+\s*;');
    if (bidRx.hasMatch(c)) { c = c.replaceAll(bidRx, 'PRODUCT_BUNDLE_IDENTIFIER = $iosBundleId;'); changed = true; }
    final nameRx = RegExp(r'PRODUCT_NAME\s*=\s*"?[^";]+"?\s*;');
    if (nameRx.hasMatch(c)) { c = c.replaceAll(nameRx, 'PRODUCT_NAME = "$newAppName";'); changed = true; }
    if (changed) { await file.writeAsString(c); ok('Updated iOS pbxproj'); }
  }
}

Future<void> i3_googleServiceInfo() async {
  step('iOS 3/4 — GoogleService-Info.plist');
  final files = await findFiles('GoogleService-Info.plist');
  if (files.isEmpty) { warn('Not found'); return; }
  for (final file in files) {
    if (file.path.contains('macos')) continue;
    String c = await file.readAsString();
    final rx = RegExp(r'(<key>BUNDLE_ID<\/key>\s*<string>)[^<]*(<\/string>)', dotAll: true);
    if (rx.hasMatch(c)) {
      c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$iosBundleId${m.group(2)}');
      await file.writeAsString(c);
      ok('BUNDLE_ID updated in GoogleService-Info.plist');
    }
  }
}

Future<void> i4_podfile() async {
  step('iOS 4/4 — Podfile');
  final f = File('ios${sep}Podfile');
  final podFile = f.existsSync() ? f : (File('ios/Podfile').existsSync() ? File('ios/Podfile') : null);
  if (podFile == null) return;
  String c = await podFile.readAsString();
  final rx = RegExp(r"bundle_identifier\s*=\s*'[a-zA-Z0-9_.]+'");
  if (rx.hasMatch(c)) {
    c = c.replaceAll(rx, "bundle_identifier = '$iosBundleId'");
    await podFile.writeAsString(c);
    ok('bundle_identifier updated in Podfile');
  }
}

// ══════════════════════════════════════════════════════════════
//  macOS, WINDOWS, WEB
// ══════════════════════════════════════════════════════════════

Future<void> runMacOsWindowsWeb() async {
  step('MAC, WINDOWS, WEB Rebranding');
  // MAC Info.plist
  for (final file in await findFiles('Info.plist')) {
    if (!file.path.contains('macos') && !file.path.contains('MacOS')) continue;
    String c = await file.readAsString();
    bool changed = false;
    void replacePlist(String key, String val) {
      final rx = RegExp('(<key>$key<\\/key>\\s*<string>)[^<]*(<\\/string>)', dotAll: true);
      if (rx.hasMatch(c)) { c = c.replaceAllMapped(rx, (m) => '${m.group(1)}$val${m.group(2)}'); changed = true; }
    }
    replacePlist('CFBundleIdentifier', macBundleId);
    replacePlist('CFBundleName', newAppName);
    replacePlist('CFBundleDisplayName', newAppName);
    if (changed) await file.writeAsString(c);
  }
  
  // MAC pbxproj
  for (final file in await findFiles('project.pbxproj')) {
    if (!file.path.contains('macos') && !file.path.contains('MacOS')) continue;
    String c = await file.readAsString();
    bool changed = false;
    final bidRx = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[a-zA-Z0-9_.]+\s*;');
    if (bidRx.hasMatch(c)) { c = c.replaceAll(bidRx, 'PRODUCT_BUNDLE_IDENTIFIER = $macBundleId;'); changed = true; }
    final nameRx = RegExp(r'PRODUCT_NAME\s*=\s*"?[^";]+"?\s*;');
    if (nameRx.hasMatch(c)) { c = c.replaceAll(nameRx, 'PRODUCT_NAME = "$newAppName";'); changed = true; }
    if (changed) await file.writeAsString(c);
  }

  // Windows CMakeLists
  for (final file in await findFiles('CMakeLists.txt')) {
    if (!file.path.contains('windows')) continue;
    String c = await file.readAsString();
    bool changed = false;
    final projRx = RegExp(r'project\s*\(\s*[a-zA-Z0-9_\s"]+\s*\)');
    if (projRx.hasMatch(c)) { c = c.replaceAll(projRx, 'project($windowsAppName)'); changed = true; }
    final binRx = RegExp(r'set\s*\(\s*BINARY_NAME\s+"?[a-zA-Z0-9_]+"?\s*\)');
    if (binRx.hasMatch(c)) { c = c.replaceAll(binRx, 'set(BINARY_NAME "$windowsAppName")'); changed = true; }
    if (changed) await file.writeAsString(c);
  }

  // Web index.html & manifest
  final webHtml = File('web/index.html');
  if (webHtml.existsSync()) {
    String c = await webHtml.readAsString();
    c = c.replaceAll(RegExp(r'<title>[^<]*<\/title>'), '<title>$newAppName</title>');
    await webHtml.writeAsString(c);
  }
  final webManifest = File('web/manifest.json');
  if (webManifest.existsSync()) {
    final Map<String, dynamic> json = jsonDecode(await webManifest.readAsString());
    if (json.containsKey('name')) json['name'] = newAppName;
    if (json.containsKey('short_name')) json['short_name'] = newAppName;
    if (json.containsKey('id')) json['id'] = webAppName;
    await webManifest.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }
  ok('macOS, Windows, and Web rebranded successfully.');
}

Future<void> c1_pubspec() async {
  step('COMMON — pubspec.yaml');
  final f = File('pubspec.yaml');
  if (!f.existsSync()) return;
  final lines = await f.readAsLines();
  final updated = lines.map((l) => l.trim().startsWith('name:') && !l.trim().startsWith('name: telecaller_app') ? 'name: $dartPackName' : l).toList();
  await f.writeAsString(updated.join('\n'));
  ok('pubspec name checked/updated');
}

// ══════════════════════════════════════════════════════════════
//  FIREBASE SETUP
// ══════════════════════════════════════════════════════════════

Future<void> setupFirebase() async {
  step('FIREBASE CONFIGURATION');
  if (firebaseProjectId.isEmpty || firebaseAppId.isEmpty) {
    warn('No Firebase info found. Skipping Firebase setup.');
    return;
  }
  
  final outPath = "android/app/google-services.json";
  print('⬇ Fetching google-services.json for $firebaseProjectId / $firebaseAppId');
  final result = await Process.run("firebase", [
    "apps:sdkconfig",
    "--project=$firebaseProjectId",
    firebaseAppId,
    "--out=$outPath"
  ], runInShell: true);

  if (result.stderr.toString().isNotEmpty && !result.stderr.toString().contains("Created")) {
    warn("Firebase SDK download note: ${result.stderr}");
  }
  if (File(outPath).existsSync()) {
    ok('google-services.json updated successfully!');
  } else {
    warn('google-services.json might not have downloaded properly.');
  }
}

Future<void> setupIcons() async {
  step('APP ICONS GENERATION');
  final iconsYaml = '''
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$appIconPath"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "$appIconPath"
  min_sdk_android: 21
  remove_alpha_ios: true
''';
  File('flutter_launcher_icons.yaml').writeAsStringSync(iconsYaml);
  ok('Created flutter_launcher_icons.yaml with path $appIconPath');

  print('🎨 Running flutter_launcher_icons to generate icons...');
  final result = await Process.run('flutter', ['pub', 'run', 'flutter_launcher_icons'], runInShell: true);
  if (result.exitCode == 0) {
    ok('Icons generated successfully.');
  } else {
    warn('Failed to generate icons. Error: ${result.stderr}');
  }
}

Future<void> ui_updateLogos() async {
  step('UPDATE UI LOGOS (Splash & Login)');
  
  final splashFile = File('lib/ui/views/splash/splash_page.dart');
  if (splashFile.existsSync()) {
    String c = await splashFile.readAsString();
    // Replaces any existing logo path in SplashPage with the new appIconPath
    final rx = RegExp(r"Image\.asset\(\s*'[A-Za-z0-9_/\.\s\(\)\-]+'");
    if (rx.hasMatch(c)) {
      c = c.replaceAll(rx, "Image.asset('$appIconPath'");
      await splashFile.writeAsString(c);
      ok('Splash Screen logo updated to $appIconPath');
    }
  }

  final loginFile = File('lib/ui/views/login/login_page.dart');
  if (loginFile.existsSync()) {
    String c = await loginFile.readAsString();
    // Replaces any existing logo path in LoginPage with the new appIconPath
    final rx = RegExp(r"Image\.asset\(\s*'[A-Za-z0-9_/\.\s\(\)\-]+'");
    if (rx.hasMatch(c)) {
      c = c.replaceAll(rx, "Image.asset('$appIconPath'");
      await loginFile.writeAsString(c);
      ok('Login Screen logo updated to $appIconPath');
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  BUILD & DISTRIBUTION
// ══════════════════════════════════════════════════════════════

Future<void> buildAndDistribute() async {
  step('BUILD & DEPLOYMENT');

  print('====================================');
  print('Building Flutter APK...');
  print('====================================');
  final buildApk = await Process.start("flutter", ["build", "apk", "--release"], runInShell: true);
  await stdout.addStream(buildApk.stdout);
  await stderr.addStream(buildApk.stderr);
  final apkCode = await buildApk.exitCode;
  
  if (apkCode != 0) {
    warn('APK Build failed!');
    exit(apkCode);
  }
  ok('APK Built Successfully!');

  print('====================================');
  print('Building Flutter AppBundle (AAB)...');
  print('====================================');
  final buildAab = await Process.start("flutter", ["build", "appbundle", "--release"], runInShell: true);
  await stdout.addStream(buildAab.stdout);
  await stderr.addStream(buildAab.stderr);
  final aabCode = await buildAab.exitCode;

  if (aabCode != 0) {
    warn('AppBundle Build failed!');
    exit(aabCode);
  }
  ok('AAB Built Successfully!');

  if (firebaseAppId.isNotEmpty) {
    final apkPath = "build/app/outputs/flutter-apk/app-release.apk";
    final aabPath = "build/app/outputs/bundle/release/app-release.aab";

    print('====================================');
    print('Uploading APK to Firebase App Distribution...');
    print('====================================');
    final uploadApk = await Process.run("firebase", [
      "appdistribution:distribute", apkPath,
      "--app=$firebaseAppId"
    ], runInShell: true);
    
    if (uploadApk.stdout.toString().contains("uploaded")) {
      ok("🎉 APK Upload Successful!");
    } else {
      print(uploadApk.stdout);
      warn(uploadApk.stderr);
    }

    print('====================================');
    print('Uploading AAB to Firebase App Distribution...');
    print('====================================');
    final uploadAab = await Process.run("firebase", [
      "appdistribution:distribute", aabPath,
      "--app=$firebaseAppId"
    ], runInShell: true);
    
    if (uploadAab.stdout.toString().contains("uploaded")) {
      ok("🎉 AAB Upload Successful!");
    } else {
      print(uploadAab.stdout);
      warn(uploadAab.stderr);
    }
  }

  print('====================================');
  print('Deployment Completed Successfully!');
  print('====================================');
}

// ══════════════════════════════════════════════════════════════
//  MAIN
// ══════════════════════════════════════════════════════════════

Future<void> main() async {
  const configPath = 'assets/config/app_config.json';
  if (!File(configPath).existsSync()) {
    print('❌ Error: Configuration file not found at $configPath');
    exit(1);
  }

  print('📖 Reading configuration...');
  final jsonStr = await File(configPath).readAsString();
  final dynamic rawConfig = jsonDecode(jsonStr);
  List<Map<String, dynamic>> configs = [];
  if (rawConfig is List) {
    configs = rawConfig.cast<Map<String, dynamic>>();
  } else {
    print('❌ Error: Invalid JSON format. Expected list of apps.');
    exit(1);
  }

  print('\n📱 Available Apps:');
  for (int i = 0; i < configs.length; i++) {
    final cfg = configs[i];
    print('  ${i + 1}. ${cfg['app_name']} (${cfg['package_name']})');
  }

  stdout.write('\n👉 Enter app number to generate (1-${configs.length}): ');
  final input = stdin.readLineSync();
  final index = int.tryParse(input ?? '') ?? -1;
  if (index < 1 || index > configs.length) {
    print('❌ Invalid selection.');
    exit(1);
  }

  final config = configs[index - 1];
  newAppName = config['app_name']?.toString() ?? 'Telecaller App';
  androidPackage = config['package_name']?.toString() ?? 'com.default.app';
  iosBundleId = androidPackage;
  macBundleId = androidPackage;
  
  String safeName = newAppName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  if (RegExp(r'^[0-9]').hasMatch(safeName)) safeName = 'app_$safeName';
  windowsAppName = safeName;
  webAppName = safeName;
  dartPackName = safeName;
  
  firebaseProjectId = config['firebase_project_id']?.toString() ?? '';
  firebaseAppId = config['app_id']?.toString() ?? '';
  appIconPath = config['app_icon']?.toString() ?? '';

  print('\n🚀 Selected Configuration:');
  print(' 🏷️  App Name: $newAppName');
  print(' 📦 Package: $androidPackage');
  print(' 🖼️  Icon: $appIconPath');
  print(' 🔑 Firebase: $firebaseProjectId ($firebaseAppId)\n');

  // Ensure flutter clean / get before doing modifications
  print('🧹 Running flutter clean & get...');
  await Process.run('flutter', ['clean'], runInShell: true);
  await Process.run('flutter', ['pub', 'get'], runInShell: true);

  await a1_buildGradle();
  await a2_manifests();
  await a4_kotlinJava();
  await a5_stringsXml();

  await i1_infoPlist();
  await i2_pbxproj();
  await i4_podfile();

  await runMacOsWindowsWeb();
  await c1_pubspec();

  if (appIconPath.isNotEmpty && File(appIconPath).existsSync()) {
    await setupIcons();
    await ui_updateLogos();
  } else {
    warn('App icon not found at $appIconPath. Skipping icon setup.');
  }

  await setupFirebase();
  
  // Re-run pub get to pick up new icon changes
  await Process.run('flutter', ['pub', 'get'], runInShell: true);

  // Auto Build and upload
  stdout.write('\n👉 Do you want to build and upload to Firebase App Distribution now? (y/N): ');
  final buildChoice = stdin.readLineSync()?.toLowerCase() ?? '';
  if (buildChoice == 'y' || buildChoice == 'yes') {
    await buildAndDistribute();
  } else {
    print('\n✅ Skiped Build & Deploy.');
  }

  print('\n🎉 Setup Completed Successfully!');
}
