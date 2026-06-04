// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:xml/xml.dart';
// // // import 'package:path/path.dart' as p;
// // // import 'package:image/image.dart' as img;
// // //
// // // /// Run a command and stream output to console. Returns exitCode.
// // // Future<int> runCmd(String exe, List<String> args,
// // //     {bool throwOnError = false}) async {
// // //   print('💻 Running: $exe ${args.join(' ')}');
// // //   final process = await Process.start(exe, args, runInShell: true);
// // //   stdout.addStream(process.stdout);
// // //   stderr.addStream(process.stderr);
// // //   final code = await process.exitCode;
// // //   if (code != 0 && throwOnError) {
// // //     throw Exception('Command failed: $exe ${args.join(' ')} (exit $code)');
// // //   }
// // //   return code;
// // // }
// // //
// // // /// Run a command and capture stdout (and stderr) — returns {exitCode, stdout, stderr}
// // // Future<Map<String, dynamic>> runCmdCapture(String exe, List<String> args) async {
// // //   print('💻 Running (capture): $exe ${args.join(' ')}');
// // //   final result = await Process.run(exe, args, runInShell: true);
// // //   return {
// // //     'exitCode': result.exitCode,
// // //     'stdout': result.stdout?.toString() ?? '',
// // //     'stderr': result.stderr?.toString() ?? ''
// // //   };
// // // }
// // //
// // // Never exitWith(String msg, [int code = 1]) {
// // //   stderr.writeln('❌ $msg');
// // //   exit(code);
// // // }
// // //
// // // void ensureExists(String path) {
// // //   if (!File(path).existsSync()) exitWith('Required file not found: $path');
// // // }
// // //
// // // Future<void> renameAndroidLabel(String filePath, String appName) async {
// // //   final file = File(filePath);
// // //   if (!file.existsSync()) {
// // //     print('⚠️ AndroidManifest.xml not found: $filePath');
// // //     return;
// // //   }
// // //   final data = await file.readAsString();
// // //   final document = XmlDocument.parse(data);
// // //   final appElement = document.findAllElements('application').isEmpty
// // //       ? null
// // //       : document.findAllElements('application').first;
// // //   if (appElement == null) {
// // //     print('⚠️ No <application> tag found in $filePath');
// // //     return;
// // //   }
// // //   appElement.setAttribute('android:label', appName);
// // //   await file.writeAsString(document.toXmlString(pretty: true, indent: ' '));
// // //   print('✅ AndroidManifest.xml label updated to "$appName"');
// // // }
// // //
// // // Future<String> readPubspecName() async {
// // //   final file = File('pubspec.yaml');
// // //   if (!file.existsSync()) return '';
// // //   final lines = await file.readAsLines();
// // //   for (final line in lines) {
// // //     if (line.trim().startsWith('name:')) {
// // //       return line.split(':').last.trim();
// // //     }
// // //   }
// // //   return '';
// // // }
// // //
// // // Future<void> updatePubspecName(String appName) async {
// // //   print('📝 Updating pubspec.yaml name...');
// // //   final file = File('pubspec.yaml');
// // //   if (!file.existsSync()) {
// // //     print('⚠️ pubspec.yaml not found');
// // //     return;
// // //   }
// // //   final lines = await file.readAsLines();
// // //   final newName = appName.toLowerCase().replaceAll(' ', '_');
// // //   final updated = lines.map((l) {
// // //     if (l.trim().startsWith('name:')) return 'name: $newName';
// // //     return l;
// // //   }).toList();
// // //   await file.writeAsString(updated.join('\n'));
// // //   print('✅ pubspec.yaml name updated to "$newName"\n');
// // // }
// // //
// // // Future<void> updateGradleNamespace(String packageName) async {
// // //   print('📝 Updating Gradle namespace and applicationId...');
// // //   final gradleFile = File('android/app/build.gradle');
// // //   if (!gradleFile.existsSync()) {
// // //     print('⚠️ build.gradle not found');
// // //     return;
// // //   }
// // //   String content = await gradleFile.readAsString();
// // //   final namespaceRegex = RegExp(r'namespace\s*=\s*"[a-zA-Z0-9_.]+"');
// // //   if (namespaceRegex.hasMatch(content)) {
// // //     content = content.replaceAllMapped(
// // //       namespaceRegex,
// // //           (_) => 'namespace = "$packageName"',
// // //     );
// // //   } else {
// // //     content = content.replaceFirst(
// // //       'android {',
// // //       'android {\n namespace = "$packageName"',
// // //     );
// // //   }
// // //   final appIdRegex = RegExp(r'applicationId\s+"[a-zA-Z0-9_.]+"');
// // //   if (appIdRegex.hasMatch(content)) {
// // //     content = content.replaceAllMapped(
// // //       appIdRegex,
// // //           (_) => 'applicationId "$packageName"',
// // //     );
// // //   }
// // //   await gradleFile.writeAsString(content);
// // //   print('✅ Gradle namespace and applicationId updated\n');
// // // }
// // //
// // // Future<void> updateDartImports(String oldPackage, String newPackage) async {
// // //   final libDir = Directory('lib');
// // //   if (!libDir.existsSync()) {
// // //     print('⚠️ lib directory not found');
// // //     return;
// // //   }
// // //   final dartFiles = libDir
// // //       .listSync(recursive: true)
// // //       .whereType<File>()
// // //       .where((f) => f.path.endsWith('.dart'));
// // //   for (var file in dartFiles) {
// // //     String content = await file.readAsString();
// // //     if (content.contains('package:$oldPackage/')) {
// // //       content = content.replaceAll('package:$oldPackage/', 'package:$newPackage/');
// // //       await file.writeAsString(content);
// // //       print('✅ Updated imports in ${file.path}');
// // //     }
// // //   }
// // // }
// // //
// // // Future<void> updateKotlinPackageStructure(String packageName) async {
// // //   print('🧩 Updating Kotlin package structure (renaming folders)...');
// // //   final baseKotlin = Directory('android/app/src/main/kotlin');
// // //   if (!baseKotlin.existsSync()) {
// // //     print('⚠️ Kotlin directory not found.');
// // //     return;
// // //   }
// // //   final allFiles = baseKotlin.listSync(recursive: true).whereType<File>();
// // //   final kotlinFiles = allFiles.where((f) => f.path.endsWith('.kt')).toList();
// // //   if (kotlinFiles.isEmpty) {
// // //     print('⚠️ No Kotlin files found.');
// // //     return;
// // //   }
// // //   final oldFile = kotlinFiles.first;
// // //   final oldDir = Directory(p.dirname(oldFile.path));
// // //   final oldRelativePath = p.relative(oldDir.path, from: baseKotlin.path);
// // //   final newRelativePath = packageName.replaceAll('.', '/');
// // //   if (oldRelativePath == newRelativePath) {
// // //     print('✅ Kotlin folder already matches package name.');
// // //   } else {
// // //     final newDirPath = p.join(baseKotlin.path, newRelativePath);
// // //     final newDirParent = Directory(p.dirname(newDirPath));
// // //     if (!newDirParent.existsSync()) {
// // //       newDirParent.createSync(recursive: true);
// // //     }
// // //     print('📁 Renaming folder:\n $oldRelativePath → $newRelativePath');
// // //     try {
// // //       oldDir.renameSync(newDirPath);
// // //     } catch (e) {
// // //       print('⚠️ Could not rename kotlin folder automatically: $e');
// // //     }
// // //   }
// // //   final updatedFiles = Directory(p.join(baseKotlin.path, newRelativePath))
// // //       .listSync(recursive: true)
// // //       .whereType<File>()
// // //       .where((f) => f.path.endsWith('.kt'));
// // //   for (final file in updatedFiles) {
// // //     String content = await file.readAsString();
// // //     final pkgRegex = RegExp(r'^package\s+[a-zA-Z0-9_.]+', multiLine: true);
// // //     content = content.replaceAllMapped(pkgRegex, (_) => 'package $packageName');
// // //     await file.writeAsString(content);
// // //     print('✅ Updated package in ${p.basename(file.path)}');
// // //   }
// // //   print('✅ Kotlin folder renamed successfully.\n');
// // // }
// // //
// // // Future<String> prepareAppIcon(String logoPath) async {
// // //   print('🎨 Preparing balanced 1024x1024 app icon...');
// // //   final bytes = await File(logoPath).readAsBytes();
// // //   final original = img.decodeImage(bytes);
// // //   if (original == null) exitWith('Could not decode image: $logoPath');
// // //   const int canvasSize = 1024;
// // //   const int paddingPx = 150;
// // //   final availableSize = canvasSize - (2 * paddingPx);
// // //   int targetWidth, targetHeight;
// // //   if (original.width >= original.height) {
// // //     targetWidth = availableSize;
// // //     targetHeight = (original.height * availableSize / original.width).toInt();
// // //   } else {
// // //     targetHeight = availableSize;
// // //     targetWidth = (original.width * availableSize / original.height).toInt();
// // //   }
// // //   final resized = img.copyResize(original, width: targetWidth, height: targetHeight);
// // //   final background = img.Image(width: canvasSize, height: canvasSize);
// // //   // img.fill(background, color: img.getColor(0, 0, 0, 0));
// // //   final offsetX = (canvasSize - targetWidth) ~/ 2;
// // //   final offsetY = (canvasSize - targetHeight) ~/ 2;
// // //   img.compositeImage(background, resized, dstX: offsetX, dstY: offsetY);
// // //   const outputPath = 'assets/images/processed_app_icon.png';
// // //   final outputFile = File(outputPath);
// // //   outputFile.createSync(recursive: true);
// // //   outputFile.writeAsBytesSync(img.encodePng(background));
// // //   print('✅ Centered icon with ${paddingPx}px padding → $outputPath');
// // //   return outputPath;
// // // }
// // //
// // // Future<void> updateGoogleServiceJsonPackage(String packageName) async {
// // //   final file = File('android/app/google-services.json');
// // //   print('\n🔥 Updating google-services.json package names...');
// // //   if (!file.existsSync()) {
// // //     print('⚠️ google-services.json not found in android/app/');
// // //     return;
// // //   }
// // //   final Map<String, dynamic> jsonContent = jsonDecode(await file.readAsString());
// // //   if (jsonContent['client'] is List) {
// // //     for (final client in jsonContent['client']) {
// // //       final clientInfo = client['client_info']?['android_client_info'];
// // //       if (clientInfo != null && clientInfo['package_name'] != null) {
// // //         clientInfo['package_name'] = packageName;
// // //       }
// // //       if (client['oauth_client'] is List) {
// // //         for (final oauth in client['oauth_client']) {
// // //           final androidInfo = oauth['android_info'];
// // //           if (androidInfo != null && androidInfo['package_name'] != null) {
// // //             androidInfo['package_name'] = packageName;
// // //           }
// // //         }
// // //       }
// // //     }
// // //   }
// // //   await file.writeAsString(const JsonEncoder.withIndent(' ').convert(jsonContent));
// // //   print('✅ All package names in google-services.json updated to → $packageName\n');
// // // }
// // //
// // // Future<void> updateAppConstantsLogo(String processedLogo) async {
// // //   const constantsPath = 'lib/constants/app_constants.dart';
// // //   final constantsFile = File(constantsPath);
// // //   if (!constantsFile.existsSync()) {
// // //     print('⚠️ AppConstants file not found at $constantsPath\n');
// // //     return;
// // //   }
// // //   print('🔍 Updating APPLOGO in AppConstants...');
// // //   String content = await constantsFile.readAsString();
// // //   final lines = content.split('\n');
// // //   bool found = false;
// // //   for (int i = 0; i < lines.length; i++) {
// // //     if (lines[i].contains('APPLOGO') && lines[i].contains('=')) {
// // //       lines[i] = ' static const String APPLOGO = "$processedLogo";';
// // //       found = true;
// // //       break;
// // //     }
// // //   }
// // //   if (found) {
// // //     await constantsFile.writeAsString(lines.join('\n'));
// // //     print('✅ APPLOGO updated to → $processedLogo\n');
// // //   } else {
// // //     print('ℹ️ No APPLOGO constant found in AppConstants.\n');
// // //   }
// // // }
// // //
// // // /// Check if Firebase CLI is authenticated
// // // Future<bool> checkFirebaseAuth() async {
// // //   final res = await runCmdCapture('firebase', ['projects:list', '--json']);
// // //   if (res['exitCode'] != 0) {
// // //     if (res['stderr'].toString().contains('not signed in') || res['stderr'].toString().contains('authentication')) {
// // //       print('⚠️ Firebase CLI not authenticated. Running firebase login...');
// // //       final loginCode = await runCmd('firebase', ['login'], throwOnError: false);
// // //       if (loginCode != 0) {
// // //         print('❌ Firebase login failed. Please run "firebase login" manually in terminal.');
// // //         return false;
// // //       }
// // //       print('✅ Firebase login successful.');
// // //       return true;
// // //     } else {
// // //       print('⚠️ Firebase projects:list failed: ${res['stderr']}');
// // //       return false;
// // //     }
// // //   }
// // //   return true;
// // // }
// // //
// // // /// Try to find an android app in the firebase project with matching package name.
// // // /// Uses `firebase apps:list --project=... --json` and parses apps.
// // // Future<String?> findAppIdInProject(String projectId, String packageName) async {
// // //   final res = await runCmdCapture('firebase', ['apps:list', '--project', projectId, '--json']);
// // //   if (res['exitCode'] != 0) {
// // //     print('⚠️ Could not list apps for project $projectId. stderr: ${res['stderr']}');
// // //     return null;
// // //   }
// // //   try {
// // //     final json = jsonDecode(res['stdout']);
// // //     // json likely has 'apps' array
// // //     final apps = json['apps'] as List<dynamic>? ?? [];
// // //     for (final a in apps) {
// // //       // try different possible fields that might contain package name
// // //       if (a is Map<String, dynamic>) {
// // //         // Fields to check: 'platform', 'appId', 'appPlatform', 'packageName', 'package_name', 'configFilename', 'displayName'
// // //         final platform = (a['platform'] ?? a['appPlatform'] ?? '').toString().toLowerCase();
// // //         final pn = (a['packageName'] ?? a['package_name'] ?? a['appId'] ?? '').toString();
// // //         // sometimes the package name is under 'androidApp' nested object
// // //         if (a.containsKey('androidApp') && a['androidApp'] is Map) {
// // //           final nested = a['androidApp'] as Map;
// // //           if (nested['packageName'] == packageName || nested['package_name'] == packageName) {
// // //             return a['appId']?.toString() ?? nested['appId']?.toString();
// // //           }
// // //         }
// // //         if (pn == packageName || a['packageName'] == packageName || a['package_name'] == packageName) {
// // //           return a['appId']?.toString();
// // //         }
// // //         // fallback: if platform is android and displayName or other fields contain packageName
// // //         if (platform.contains('android') && (a['appId'] != null)) {
// // //           // try to detect package name inside nested fields
// // //           if (a.toString().contains(packageName)) {
// // //             return a['appId']?.toString();
// // //           }
// // //         }
// // //       }
// // //     }
// // //   } catch (e) {
// // //     print('⚠️ Parsing apps:list JSON failed: $e');
// // //     print('Raw stdout: ${res['stdout']}');
// // //   }
// // //   return null;
// // // }
// // //
// // // /// Create Android app in Firebase project and return appId (if created)
// // // Future<String?> createFirebaseAndroidApp(String projectId, String packageName, String displayName) async {
// // //   // Corrected Syntax: firebase apps:create android <DISPLAY_NAME> --package-name <PACKAGE_NAME> --project <PROJECT_ID> [--json]
// // //   final res = await runCmdCapture('firebase', [
// // //     'apps:create',
// // //     'android',
// // //     displayName,
// // //     '--package-name',
// // //     packageName,
// // //     '--project',
// // //     projectId,
// // //     '--json'
// // //   ]);
// // //   if (res['exitCode'] != 0) {
// // //     print('⚠️ firebase apps:create failed. stderr: ${res['stderr']}');
// // //     return null;
// // //   }
// // //   try {
// // //     final json = jsonDecode(res['stdout']);
// // //     // structure may contain 'appId' or 'id'. try to pick.
// // //     if (json is Map<String, dynamic>) {
// // //       if (json['appId'] != null) return json['appId'].toString();
// // //       if (json['id'] != null) return json['id'].toString();
// // //       // sometimes the output is { "name": "...", "appId": "..." }
// // //       if (json.containsKey('name') && json.containsKey('appId')) return json['appId'].toString();
// // //     }
// // //   } catch (e) {
// // //     print('⚠️ Could not parse apps:create output: $e');
// // //     print('stdout: ${res['stdout']}');
// // //   }
// // //   // last resort: try to extract appId by regex
// // //   final stdout = res['stdout'] as String;
// // //   // final match = RegExp(r'appId[:=]\s*["\']?([A-Za-z0-9:_-]+)["\']?', caseSensitive: false).firstMatch(stdout);
// // //   // if (match != null) return match.group(1);
// // //   return null;
// // // }
// // //
// // // Future<bool> downloadSdkConfig(String projectId, String appId) async {
// // //   // Use apps:sdkconfig with android-app param and write directly to android/app/google-services.json
// // //   final outfile = 'android/app/google-services.json';
// // //   final code = await runCmd('firebase', [
// // //     'apps:sdkconfig',
// // //     '--project',
// // //     projectId,
// // //     '--android-app',
// // //     appId,
// // //     '--out',
// // //     outfile
// // //   ]);
// // //   if (code == 0) {
// // //     print('✅ Downloaded google-services.json → $outfile');
// // //     return true;
// // //   } else {
// // //     print('⚠️ Could not download google-services.json via firebase apps:sdkconfig');
// // //     return false;
// // //   }
// // // }
// // //
// // // Future<void> main() async {
// // //   const configPath = 'assets/config/app_config.json';
// // //   ensureExists(configPath);
// // //   print('📖 Reading configuration...');
// // //   final jsonStr = await File(configPath).readAsString();
// // //   final dynamic rawConfig = jsonDecode(jsonStr);
// // //   List<Map<String, dynamic>> configs = [];
// // //   if (rawConfig is List) {
// // //     configs = rawConfig.cast<Map<String, dynamic>>();
// // //   } else if (rawConfig is Map<String, dynamic>) {
// // //     configs = [rawConfig];
// // //   } else {
// // //     exitWith('Invalid JSON format. Must be object or list of objects.');
// // //   }
// // //   print('\n📱 Available Apps:');
// // //   for (int i = 0; i < configs.length; i++) {
// // //     final cfg = configs[i];
// // //     print(' ${i + 1}. ${cfg['app_name']} (${cfg['package_name']}) firebase:${cfg['firebase_project_id'] ?? "<none>"}');
// // //   }
// // //   stdout.write('\n👉 Enter app number to rebrand (1-${configs.length}): ');
// // //   final input = stdin.readLineSync();
// // //   final index = int.tryParse(input ?? '') ?? -1;
// // //   if (index < 1 || index > configs.length) exitWith('Invalid selection.');
// // //   final config = configs[index - 1];
// // //   final appName = config['app_name']?.toString() ?? '';
// // //   final packageName = config['package_name']?.toString() ?? '';
// // //   final logoPath = config['app_icon']?.toString() ?? '';
// // //   final firebaseProjectId = config['firebase_project_id']?.toString() ?? '';
// // //   if (appName.isEmpty || packageName.isEmpty || logoPath.isEmpty) {
// // //     exitWith('Invalid configuration data for selected app.');
// // //   }
// // //   if (!File(logoPath).existsSync()) exitWith('Logo file not found: $logoPath');
// // //   print('\n🚀 Selected Configuration:');
// // //   print(' 🏷️ App Name: $appName');
// // //   print(' 📦 Package: $packageName');
// // //   print(' 🖼️ Logo Path: $logoPath');
// // //   print(' 🔑 Firebase Project: $firebaseProjectId\n');
// // //   // Prepare icon
// // //   final processedLogo = await prepareAppIcon(logoPath);
// // //   // Write flutter_launcher_icons.yaml
// // //   final iconsYaml = '''
// // // flutter_launcher_icons:
// // //   android: true
// // //   ios: true
// // //   image_path: "$processedLogo"
// // //   adaptive_icon_background: "#ffffff"
// // //   adaptive_icon_foreground: "$processedLogo"
// // //   min_sdk_android: 21
// // //   remove_alpha_ios: true
// // // ''';
// // //   File('flutter_launcher_icons.yaml').writeAsStringSync(iconsYaml);
// // //   print('✅ Created flutter_launcher_icons.yaml\n');
// // //   await updateAppConstantsLogo(logoPath);
// // //   // Run flutter pub get
// // //   var ec = await runCmd('flutter', ['pub', 'get']);
// // //   if (ec != 0) exitWith('flutter pub get failed');
// // //   // Generate launcher icons
// // //   ec = await runCmd('flutter', ['pub', 'run', 'flutter_launcher_icons']);
// // //   if (ec != 0) {
// // //     print('⚠️ flutter_launcher_icons failed. Continue anyway.');
// // //   }
// // //   // Get old package name
// // //   final oldPackage = await readPubspecName();
// // //   print('📦 Old package name detected: $oldPackage');
// // //   // Android label
// // //   await renameAndroidLabel('android/app/src/main/AndroidManifest.xml', appName);
// // //   // Update pubspec name and gradle
// // //   await updatePubspecName(appName);
// // //   await updateGradleNamespace(packageName);
// // //   // Update dart imports
// // //   final newPackage = appName.toLowerCase().replaceAll(' ', '_');
// // //   await updateDartImports(oldPackage, newPackage);
// // //   // Kotlin restructure
// // //   await updateKotlinPackageStructure(packageName);
// // //   // ---- FIREBASE: create/find android app in firebase project and download google-services.json ----
// // //   if (firebaseProjectId.isEmpty) {
// // //     print('⚠️ No firebase_project_id provided for this app. Skipping firebase automation.');
// // //   } else {
// // //     // Ensure firebase CLI installed and authenticated
// // //     final fvCheck = await runCmdCapture('firebase', ['--version']);
// // //     if (fvCheck['exitCode'] != 0) {
// // //       print('⚠️ Firebase CLI not found. Attempting to install via npm (requires npm).');
// // //       final npmRc = await runCmd('npm', ['install', '-g', 'firebase-tools']);
// // //       if (npmRc != 0) {
// // //         print('❌ Could not install firebase-tools. Please install manually and re-run.');
// // //       }
// // //     }
// // //     final authOk = await checkFirebaseAuth();
// // //     if (!authOk) {
// // //       print('❌ Firebase authentication failed. Skipping Firebase automation.');
// // //     } else {
// // //       // 1) find existing app (by package name)
// // //       String? appId = await findAppIdInProject(firebaseProjectId, packageName);
// // //       if (appId != null) {
// // //         print('ℹ️ Found existing Firebase Android app in project -> appId: $appId');
// // //       } else {
// // //         print('ℹ️ No existing Android app found for package $packageName. Creating one now...');
// // //         appId = await createFirebaseAndroidApp(firebaseProjectId, packageName, appName);
// // //         if (appId == null) {
// // //           print('❌ Failed to create Firebase Android app. You may need to create it manually in the Firebase console.');
// // //         } else {
// // //           print('✅ Created Firebase Android app -> appId: $appId');
// // //           // Note: Display name is set via the command now.
// // //         }
// // //       }
// // //       // 2) download google-services.json using apps:sdkconfig
// // //       if (appId != null) {
// // //         final ok = await downloadSdkConfig(firebaseProjectId, appId);
// // //         if (!ok) {
// // //           print('⚠️ apps:sdkconfig method failed. Trying fallback: apps:sdkconfig --json and write file manually.');
// // //           final res = await runCmdCapture('firebase', [
// // //             'apps:sdkconfig',
// // //             '--project',
// // //             firebaseProjectId,
// // //             '--android-app',
// // //             appId,
// // //             '--json'
// // //           ]);
// // //           if (res['exitCode'] == 0) {
// // //             try {
// // //               final obj = jsonDecode(res['stdout']);
// // //               // trying to find config json in output
// // //               if (obj is Map && obj['config'] != null) {
// // //                 final outfile = 'android/app/google-services.json';
// // //                 await File(outfile).writeAsString(const JsonEncoder.withIndent(' ').convert(obj['config']));
// // //                 print('✅ Wrote google-services.json from sdkconfig JSON to $outfile');
// // //               } else {
// // //                 print('⚠️ Unexpected sdkconfig JSON format: ${res['stdout']}');
// // //               }
// // //             } catch (e) {
// // //               print('⚠️ Could not parse sdkconfig JSON: $e');
// // //             }
// // //           } else {
// // //             print('⚠️ apps:sdkconfig also failed: ${res['stderr']}');
// // //           }
// // //         } else {
// // //           // update package name inside google-services.json to ensure correct package
// // //           await updateGoogleServiceJsonPackage(packageName);
// // //         }
// // //       }
// // //     }
// // //   }
// // //   // Run change_app_package_name tool to update Android/iOS package identifiers (if installed)
// // //   print('🏷 Changing Android package structure (change_app_package_name) ...');
// // //   ec = await runCmd('flutter', [
// // //     'pub',
// // //     'run',
// // //     'change_app_package_name:main',
// // //     packageName,
// // //   ]);
// // //   if (ec != 0) {
// // //     print('⚠️ Could not change Android package name automatically with change_app_package_name package.');
// // //   } else {
// // //     print('✅ Android package name changed successfully\n');
// // //   }
// // //   // Try flutterfire configure (generate firebase_options.dart) - Auto-overwrite with --yes
// // //   if (firebaseProjectId.isNotEmpty) {
// // //     print('🔗 Running flutterfire configure to update firebase_options.dart (auto-overwrite)...');
// // //     ec = await runCmd('flutterfire', ['configure', '--project=$firebaseProjectId', '--platforms=android', '--yes']);
// // //     if (ec != 0) {
// // //       print('⚠️ flutterfire configure failed or is not installed. You can run it manually: flutterfire configure --project=$firebaseProjectId --platforms=android --yes');
// // //     } else {
// // //       print('✅ firebase_options.dart auto-updated without prompts.');
// // //     }
// // //   }
// // //   // Clean and get dependencies before build
// // //   print('\n🧹 Running flutter clean...');
// // //   await runCmd('flutter', ['clean']);
// // //   await runCmd('flutter', ['pub', 'get']);
// // //
// // //   // Build APK and AAB automatically
// // //   print('\n🔨 Building APK...');
// // //   final apkEc = await runCmd('flutter', ['build', 'apk', '--release']);
// // //   if (apkEc == 0) {
// // //     print('✅ APK built successfully! Location: build/app/outputs/flutter-apk/app-release.apk');
// // //   } else {
// // //     print('⚠️ APK build failed. Check errors above.');
// // //   }
// // //
// // //   print('\n🔨 Building AAB...');
// // //   final aabEc = await runCmd('flutter', ['build', 'appbundle', '--release']);
// // //   if (aabEc == 0) {
// // //     print('✅ AAB built successfully! Location: build/app/outputs/bundle/release/app-release.aab');
// // //   } else {
// // //     print('⚠️ AAB build failed. Check errors above.');
// // //   }
// // //
// // //   print('\n🎉 Setup & Build Complete!');
// // //   print('📋 Verify changes in:');
// // //   print(' • android/app/build.gradle');
// // //   print(' • android/app/src/main/AndroidManifest.xml');
// // //   print(' • android/app/google-services.json');
// // //   print(' • pubspec.yaml');
// // //   print(' • lib/ imports updated');
// // //   print(' • firebase_options.dart (auto-overwritten)');
// // //   print(' • APK: build/app/outputs/flutter-apk/app-release.apk');
// // //   print(' • AAB: build/app/outputs/bundle/release/app-release.aab\n');
// // //   print('✅ Done! You can now install or upload the builds.');
// // // }
// // //
// //
// //
// //
// //
// //
// // ///---------------------- app distributions code------------------------------------  ///
// // ///---------------------- app distributions code------------------------------------  ///
// //
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:path/path.dart' as p;
// //
// // /// --------------------------------------------------------------
// // /// CONFIGURATION
// // /// --------------------------------------------------------------
// // const FIREBASE_PROJECT_ID = "apidemlo";
// // const FIREBASE_ANDROID_APP_ID =
// //     "1:1036394779270:android:1ad51962422cc04a947707";
// // const TESTERS = ["ankitamahajan738@gmail.com"];
// //
// //
// // Future<void> main() async {
// //   print("📱 CRM Auto App Setup Started...\n");
// //
// //   await _checkFirebaseLogin();
// //   await _fetchGoogleServiceJson();
// //   await _buildReleaseApk();
// //   await _uploadToFirebaseDistribution();
// //
// //   print("\n🎉 Setup Completed Successfully!");
// // }
// //
// // /// --------------------------------------------------------------
// // /// 1. CHECK FIREBASE LOGIN
// // /// --------------------------------------------------------------
// // Future<void> _checkFirebaseLogin() async {
// //   print(" Checking Firebase Login...");
// //
// //   // Added runInShell: true for Windows compatibility
// //   final result = await Process.run("firebase", ["login:list"], runInShell: true);
// //
// //   if (result.stdout.toString().contains("No authorized")) {
// //     print("⚠ Firebase login required...");
// //     await Process.run("firebase", ["login"], runInShell: true);
// //   } else {
// //     print(" Already Logged In!");
// //   }
// // }
// //
// // /// --------------------------------------------------------------
// // /// 2. DOWNLOAD google-services.json & plist
// // /// --------------------------------------------------------------
// // Future<void> _fetchGoogleServiceJson() async {
// //   print("\n⬇ Fetching google-services.json...");
// //
// //   final outPath = "android/app/google-services.json";
// //
// //   // Added runInShell: true for Windows compatibility
// //   final result = await Process.run("firebase", [
// //     "apps:sdkconfig",
// //     "--project=$FIREBASE_PROJECT_ID",
// //     FIREBASE_ANDROID_APP_ID,
// //     "--out=$outPath"
// //   ], runInShell: true);
// //
// //   if (result.stderr.toString().isNotEmpty) {
// //     print(" Error downloading google-services.json");
// //     print(result.stderr);
// //   } else {
// //     print("✔ google-services.json updated!");
// //   }
// // }
// //
// // /// --------------------------------------------------------------
// // /// 3. BUILD RELEASE APK
// // /// --------------------------------------------------------------
// // Future<void> _buildReleaseApk() async {
// //   print("\n Building Release APK...\n");
// //
// //   final build = await Process.start(
// //     "flutter",
// //     ["build", "apk", "--release"],
// //     runInShell: true,
// //   );
// //
// //   await stdout.addStream(build.stdout);
// //   await stderr.addStream(build.stderr);
// //
// //   print("✔ APK Generated!");
// // }
// //
// // /// --------------------------------------------------------------
// // /// 4. UPLOAD APK TO FIREBASE APP DISTRIBUTION
// // /// --------------------------------------------------------------
// // Future<void> _uploadToFirebaseDistribution() async {
// //   print("\n🚀 Uploading to Firebase App Distribution...");
// //
// //   final apkPath = "build/app/outputs/flutter-apk/app-release.apk";
// //
// //   if (!File(apkPath).existsSync()) {
// //     print(" APK not found: $apkPath");
// //     return;
// //   }
// //
// //   // Added runInShell: true for Windows compatibility
// //   final result = await Process.run("firebase", [
// //     "appdistribution:distribute",
// //     apkPath,
// //     "--app=$FIREBASE_ANDROID_APP_ID",
// //     "--project=$FIREBASE_PROJECT_ID",
// //     "--testers=${TESTERS.join(",")}",
// //     "--release-notes=Automated build from app_setup.dart"
// //   ], runInShell: true);
// //
// //   if (result.stderr.toString().isNotEmpty &&
// //       !result.stderr.toString().contains("error")) {
// //     print("⚠ Some warnings:");
// //     print(result.stderr);
// //   }
// //
// //   if (result.stdout.toString().contains("uploaded")) {
// //     print("🎉 Upload Successful!");
// //   } else {
// //     print(result.stdout);
// //   }
// // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// import 'dart:convert';
// import 'dart:io';
// import 'package:xml/xml.dart';
// import 'package:path/path.dart' as p;
// import 'package:image/image.dart' as img;
//
// // Hardcoded Firebase constants
// const String FIREBASE_PROJECT_ID = "apidemlo";
// const String FIREBASE_ANDROID_APP_ID = "1:1036394779270:android:9cadb881a7d6c1ea947707";
// const List<String> TESTERS = ["ankitamahajan738@gmail.com"];
//
// Future<int> runCmd(String exe, List<String> args, {bool throwOnError = false}) async {
//   print('💻 Running: $exe ${args.join(' ')}');
//   final process = await Process.start(exe, args, runInShell: true);
//   stdout.addStream(process.stdout);
//   stderr.addStream(process.stderr);
//   final code = await process.exitCode;
//   if (code != 0 && throwOnError) {
//     throw Exception('Command failed: $exe ${args.join(' ')} (exit $code)');
//   }
//   return code;
// }
//
// Future<Map<String, dynamic>> runCmdCapture(String exe, List<String> args) async {
//   print('💻 Running (capture): $exe ${args.join(' ')}');
//   final result = await Process.run(exe, args, runInShell: true);
//   return {
//     'exitCode': result.exitCode,
//     'stdout': result.stdout?.toString() ?? '',
//     'stderr': result.stderr?.toString() ?? ''
//   };
// }
//
// Never exitWith(String msg, [int code = 1]) {
//   stderr.writeln('$msg');
//   exit(code);
// }
//
// void ensureExists(String path) {
//   if (!File(path).existsSync()) exitWith('Required file not found: $path');
// }
//
// Future<void> renameAndroidLabel(String filePath, String appName) async {
//   final file = File(filePath);
//   if (!file.existsSync()) {
//     print('⚠️ AndroidManifest.xml not found: $filePath');
//     return;
//   }
//   final data = await file.readAsString();
//   final document = XmlDocument.parse(data);
//   final appElement = document.findAllElements('application').isEmpty
//       ? null
//       : document.findAllElements('application').first;
//   if (appElement == null) {
//     print('⚠️ No <application> tag found in $filePath');
//     return;
//   }
//   appElement.setAttribute('android:label', appName);
//   await file.writeAsString(document.toXmlString(pretty: true, indent: ' '));
//   print('✅ AndroidManifest.xml label updated to "$appName"');
// }
//
// Future<String> readPubspecName() async {
//   final file = File('pubspec.yaml');
//   if (!file.existsSync()) return '';
//   final lines = await file.readAsLines();
//   for (final line in lines) {
//     if (line.trim().startsWith('name:')) {
//       return line.split(':').last.trim();
//     }
//   }
//   return '';
// }
//
// Future<void> updatePubspecName(String appName) async {
//   print('📝 Updating pubspec.yaml name...');
//   final file = File('pubspec.yaml');
//   if (!file.existsSync()) {
//     print('⚠️ pubspec.yaml not found');
//     return;
//   }
//   final lines = await file.readAsLines();
//   final newName = appName.toLowerCase().replaceAll(' ', '_');
//   final updated = lines.map((l) {
//     if (l.trim().startsWith('name:')) return 'name: $newName';
//     return l;
//   }).toList();
//   await file.writeAsString(updated.join('\n'));
//   print('✅ pubspec.yaml name updated to "$newName"\n');
// }
//
// Future<void> updateGradleNamespace(String packageName) async {
//   print('📝 Updating Gradle namespace and applicationId...');
//   final gradleFile = File('android/app/build.gradle');
//   if (!gradleFile.existsSync()) {
//     print('⚠️ build.gradle not found');
//     return;
//   }
//   String content = await gradleFile.readAsString();
//   final namespaceRegex = RegExp(r'namespace\s*=\s*"[a-zA-Z0-9_.]+"');
//   if (namespaceRegex.hasMatch(content)) {
//     content = content.replaceAllMapped(
//       namespaceRegex,
//           (_) => 'namespace = "$packageName"',
//     );
//   } else {
//     content = content.replaceFirst(
//       'android {',
//       'android {\n namespace = "$packageName"',
//     );
//   }
//   final appIdRegex = RegExp(r'applicationId\s+"[a-zA-Z0-9_.]+"');
//   if (appIdRegex.hasMatch(content)) {
//     content = content.replaceAllMapped(
//       appIdRegex,
//           (_) => 'applicationId "$packageName"',
//     );
//   }
//   await gradleFile.writeAsString(content);
//   print('✅ Gradle namespace and applicationId updated\n');
// }
//
// Future<void> updateDartImports(String oldPackage, String newPackage) async {
//   final libDir = Directory('lib');
//   if (!libDir.existsSync()) {
//     print('⚠️ lib directory not found');
//     return;
//   }
//   final dartFiles = libDir
//       .listSync(recursive: true)
//       .whereType<File>()
//       .where((f) => f.path.endsWith('.dart'));
//   for (var file in dartFiles) {
//     String content = await file.readAsString();
//     if (content.contains('package:$oldPackage/')) {
//       content = content.replaceAll('package:$oldPackage/', 'package:$newPackage/');
//       await file.writeAsString(content);
//       print('✅ Updated imports in ${file.path}');
//     }
//   }
// }
//
// Future<void> updateKotlinPackageStructure(String packageName) async {
//   print('🧩 Updating Kotlin package structure (renaming folders)...');
//   final baseKotlin = Directory('android/app/src/main/kotlin');
//   if (!baseKotlin.existsSync()) {
//     print('⚠️ Kotlin directory not found.');
//     return;
//   }
//   final allFiles = baseKotlin.listSync(recursive: true).whereType<File>();
//   final kotlinFiles = allFiles.where((f) => f.path.endsWith('.kt')).toList();
//   if (kotlinFiles.isEmpty) {
//     print('⚠️ No Kotlin files found.');
//     return;
//   }
//   final oldFile = kotlinFiles.first;
//   final oldDir = Directory(p.dirname(oldFile.path));
//   final oldRelativePath = p.relative(oldDir.path, from: baseKotlin.path);
//   final newRelativePath = packageName.replaceAll('.', '/');
//   if (oldRelativePath == newRelativePath) {
//     print('✅ Kotlin folder already matches package name.');
//   } else {
//     final newDirPath = p.join(baseKotlin.path, newRelativePath);
//     final newDirParent = Directory(p.dirname(newDirPath));
//     if (!newDirParent.existsSync()) {
//       newDirParent.createSync(recursive: true);
//     }
//     print('📁 Renaming folder:\n $oldRelativePath → $newRelativePath');
//     try {
//       oldDir.renameSync(newDirPath);
//     } catch (e) {
//       print('⚠️ Could not rename kotlin folder automatically: $e');
//     }
//   }
//   final updatedFiles = Directory(p.join(baseKotlin.path, newRelativePath))
//       .listSync(recursive: true)
//       .whereType<File>()
//       .where((f) => f.path.endsWith('.kt'));
//   for (final file in updatedFiles) {
//     String content = await file.readAsString();
//     final pkgRegex = RegExp(r'^package\s+[a-zA-Z0-9_.]+', multiLine: true);
//     content = content.replaceAllMapped(pkgRegex, (_) => 'package $packageName');
//     await file.writeAsString(content);
//     print('✅ Updated package in ${p.basename(file.path)}');
//   }
//   print('✅ Kotlin folder renamed successfully.\n');
// }
//
// Future<String> prepareAppIcon(String logoPath) async {
//   print('🎨 Preparing balanced 1024x1024 app icon...');
//   final bytes = await File(logoPath).readAsBytes();
//   final original = img.decodeImage(bytes);
//   if (original == null) exitWith('Could not decode image: $logoPath');
//   const int canvasSize = 1024;
//   const int paddingPx = 150;
//   final availableSize = canvasSize - (2 * paddingPx);
//   int targetWidth, targetHeight;
//   if (original.width >= original.height) {
//     targetWidth = availableSize;
//     targetHeight = (original.height * availableSize / original.width).toInt();
//   } else {
//     targetHeight = availableSize;
//     targetWidth = (original.width * availableSize / original.height).toInt();
//   }
//   final resized = img.copyResize(original, width: targetWidth, height: targetHeight);
//   final background = img.Image(width: canvasSize, height: canvasSize);
//   final offsetX = (canvasSize - targetWidth) ~/ 2;
//   final offsetY = (canvasSize - targetHeight) ~/ 2;
//   img.compositeImage(background, resized, dstX: offsetX, dstY: offsetY);
//   const outputPath = 'assets/images/processed_app_icon.png';
//   final outputFile = File(outputPath);
//   outputFile.createSync(recursive: true);
//   outputFile.writeAsBytesSync(img.encodePng(background));
//   print('✅ Centered icon with ${paddingPx}px padding → $outputPath');
//   return outputPath;
// }
//
// Future<void> updateGoogleServiceJsonPackage(String packageName) async {
//   final file = File('android/app/google-services.json');
//   print('\n🔥 Updating google-services.json package names...');
//   if (!file.existsSync()) {
//     print('⚠️ google-services.json not found in android/app/');
//     return;
//   }
//   final Map<String, dynamic> jsonContent = jsonDecode(await file.readAsString());
//   if (jsonContent['client'] is List) {
//     for (final client in jsonContent['client']) {
//       final clientInfo = client['client_info']?['android_client_info'];
//       if (clientInfo != null && clientInfo['package_name'] != null) {
//         clientInfo['package_name'] = packageName;
//       }
//       if (client['oauth_client'] is List) {
//         for (final oauth in client['oauth_client']) {
//           final androidInfo = oauth['android_info'];
//           if (androidInfo != null && androidInfo['package_name'] != null) {
//             androidInfo['package_name'] = packageName;
//           }
//         }
//       }
//     }
//   }
//   await file.writeAsString(const JsonEncoder.withIndent(' ').convert(jsonContent));
//   print('✅ All package names in google-services.json updated to → $packageName\n');
// }
//
// Future<void> updateAppConstantsLogo(String processedLogo) async {
//   const constantsPath = 'lib/constants/app_constants.dart';
//   final constantsFile = File(constantsPath);
//   if (!constantsFile.existsSync()) {
//     print('⚠️ AppConstants file not found at $constantsPath\n');
//     return;
//   }
//   print('🔍 Updating APPLOGO in AppConstants...');
//   String content = await constantsFile.readAsString();
//   final lines = content.split('\n');
//   bool found = false;
//   for (int i = 0; i < lines.length; i++) {
//     if (lines[i].contains('APPLOGO') && lines[i].contains('=')) {
//       lines[i] = ' static const String APPLOGO = "$processedLogo";';
//       found = true;
//       break;
//     }
//   }
//   if (found) {
//     await constantsFile.writeAsString(lines.join('\n'));
//     print('✅ APPLOGO updated to → $processedLogo\n');
//   } else {
//     print('ℹ️ No APPLOGO constant found in AppConstants.\n');
//   }
// }
//
// Future<bool> checkFirebaseAuth() async {
//   final res = await runCmdCapture('firebase', ['projects:list', '--json']);
//   if (res['exitCode'] != 0) {
//     if (res['stderr'].toString().contains('not signed in') || res['stderr'].toString().contains('authentication')) {
//       print('⚠️ Firebase CLI not authenticated. Running firebase login...');
//       final loginCode = await runCmd('firebase', ['login'], throwOnError: false);
//       if (loginCode != 0) {
//         print('❌ Firebase login failed. Please run "firebase login" manually in terminal.');
//         return false;
//       }
//       print('✅ Firebase login successful.');
//       return true;
//     } else {
//       print('⚠️ Firebase projects:list failed: ${res['stderr']}');
//       return false;
//     }
//   }
//   return true;
// }
//
// Future<bool> downloadSdkConfig(String projectId, String appId) async {
//   final outfile = 'android/app/google-services.json';
//   final code = await runCmd('firebase', [
//     'apps:sdkconfig',
//     '--project',
//     projectId,
//     '--android-app',
//     appId,
//     '--out',
//     outfile
//   ]);
//   if (code == 0) {
//     print('✅ Downloaded google-services.json → $outfile');
//     return true;
//   } else {
//     print('⚠️ Could not download google-services.json via firebase apps:sdkconfig');
//     return false;
//   }
// }
//
// Future<void> uploadToFirebaseDistribution(String firebaseProjectId, String androidAppId, List<String> testers) async {
//   print("\n🚀 Uploading to Firebase App Distribution...");
//   final apkPath = "build/app/outputs/flutter-apk/app-release.apk";
//   if (!File(apkPath).existsSync()) {
//     print(" APK not found: $apkPath");
//     return;
//   }
//   final result = await Process.run("firebase", [
//     "appdistribution:distribute",
//     apkPath,
//     "--app=$androidAppId",
//     "--project=$firebaseProjectId",
//     "--testers=${testers.join(",")}",
//     "--release-notes=Automated build from app_setup.dart"
//   ], runInShell: true);
//   if (result.stderr.toString().isNotEmpty &&
//       !result.stderr.toString().contains("error")) {
//     print("⚠ Some warnings:");
//     print(result.stderr);
//   }
//   if (result.stdout.toString().contains("uploaded")) {
//     print("🎉 Upload Successful!");
//   } else {
//     print(result.stdout);
//   }
// }
//
// Future<void> main() async {
//   const configPath = 'assets/config/app_config.json';
//   ensureExists(configPath);
//   print('📖 Reading configuration...');
//   final jsonStr = await File(configPath).readAsString();
//   final dynamic rawConfig = jsonDecode(jsonStr);
//   List<Map<String, dynamic>> configs = [];
//   if (rawConfig is List) {
//     configs = rawConfig.cast<Map<String, dynamic>>();
//   } else if (rawConfig is Map<String, dynamic>) {
//     configs = [rawConfig];
//   } else {
//     exitWith('Invalid JSON format. Must be object or list of objects.');
//   }
//   print('\n📱 Available Apps:');
//   for (int i = 0; i < configs.length; i++) {
//     final cfg = configs[i];
//     print(' ${i + 1}. ${cfg['app_name']} (${cfg['package_name']}) firebase:${cfg['firebase_project_id'] ?? "<none>"}');
//   }
//   stdout.write('\n👉 Enter app number to rebrand (1-${configs.length}): ');
//   final input = stdin.readLineSync();
//   final index = int.tryParse(input ?? '') ?? -1;
//   if (index < 1 || index > configs.length) exitWith('Invalid selection.');
//   final config = configs[index - 1];
//   final appName = config['app_name']?.toString() ?? '';
//   final packageName = config['package_name']?.toString() ?? '';
//   final logoPath = config['app_icon']?.toString() ?? '';
//   String firebaseProjectId = config['firebase_project_id']?.toString() ?? FIREBASE_PROJECT_ID;
//   if (appName.isEmpty || packageName.isEmpty || logoPath.isEmpty) {
//     exitWith('Invalid configuration data for selected app.');
//   }
//   if (!File(logoPath).existsSync()) exitWith('Logo file not found: $logoPath');
//   print('\n🚀 Selected Configuration:');
//   print(' 🏷️ App Name: $appName');
//   print(' 📦 Package: $packageName');
//   print(' 🖼️ Logo Path: $logoPath');
//   print(' 🔑 Firebase Project: $firebaseProjectId\n');
//   final processedLogo = await prepareAppIcon(logoPath);
//   final iconsYaml = '''
// flutter_launcher_icons:
//   android: true
//   ios: true
//   image_path: "$processedLogo"
//   adaptive_icon_background: "#ffffff"
//   adaptive_icon_foreground: "$processedLogo"
//   min_sdk_android: 21
//   remove_alpha_ios: true
// ''';
//   File('flutter_launcher_icons.yaml').writeAsStringSync(iconsYaml);
//   print('✅ Created flutter_launcher_icons.yaml\n');
//   await updateAppConstantsLogo(logoPath);
//   var ec = await runCmd('flutter', ['pub', 'get']);
//   if (ec != 0) exitWith('flutter pub get failed');
//   ec = await runCmd('flutter', ['pub', 'run', 'flutter_launcher_icons']);
//   if (ec != 0) {
//     print('⚠️ flutter_launcher_icons failed. Continue anyway.');
//   }
//   final oldPackage = await readPubspecName();
//   print('📦 Old package name detected: $oldPackage');
//   await renameAndroidLabel('android/app/src/main/AndroidManifest.xml', appName);
//   await updatePubspecName(appName);
//   await updateGradleNamespace(packageName);
//   final newPackage = appName.toLowerCase().replaceAll(' ', '_');
//   await updateDartImports(oldPackage, newPackage);
//   await updateKotlinPackageStructure(packageName);
//   String? appId = FIREBASE_ANDROID_APP_ID; // Hardcode appId
//   if (firebaseProjectId.isEmpty) {
//     print('⚠️ No firebase_project_id provided for this app. Skipping firebase automation.');
//   } else {
//     final fvCheck = await runCmdCapture('firebase', ['--version']);
//     if (fvCheck['exitCode'] != 0) {
//       print('⚠️ Firebase CLI not found. Attempting to install via npm (requires npm).');
//       final npmRc = await runCmd('npm', ['install', '-g', 'firebase-tools']);
//       if (npmRc != 0) {
//         print('❌ Could not install firebase-tools. Please install manually and re-run.');
//       }
//     }
//     final authOk = await checkFirebaseAuth();
//     if (!authOk) {
//       print('❌ Firebase authentication failed. Skipping Firebase automation.');
//     } else {
//       print('ℹ️ Using hardcoded Firebase Android appId: $appId');
//       // Download google-services.json using hardcoded appId
//       final ok = await downloadSdkConfig(firebaseProjectId, appId);
//       if (!ok) {
//         print('⚠️ apps:sdkconfig method failed. Trying fallback: apps:sdkconfig --json and write file manually.');
//         final res = await runCmdCapture('firebase', [
//           'apps:sdkconfig',
//           '--project',
//           firebaseProjectId,
//           '--android-app',
//           appId,
//           '--json'
//         ]);
//         if (res['exitCode'] == 0) {
//           try {
//             final obj = jsonDecode(res['stdout']);
//             if (obj is Map && obj['config'] != null) {
//               final outfile = 'android/app/google-services.json';
//               await File(outfile).writeAsString(const JsonEncoder.withIndent(' ').convert(obj['config']));
//               print('✅ Wrote google-services.json from sdkconfig JSON to $outfile');
//             } else {
//               print('⚠️ Unexpected sdkconfig JSON format: ${res['stdout']}');
//             }
//           } catch (e) {
//             print('⚠️ Could not parse sdkconfig JSON: $e');
//           }
//         } else {
//           print('⚠️ apps:sdkconfig also failed: ${res['stderr']}');
//         }
//       } else {
//         await updateGoogleServiceJsonPackage(packageName); // Update to new package
//       }
//     }
//   }
//   print('🏷 Changing Android package structure (change_app_package_name) ...');
//   ec = await runCmd('flutter', [
//     'pub',
//     'run',
//     'change_app_package_name:main',
//     packageName,
//   ]);
//   if (ec != 0) {
//     print('⚠️ Could not change Android package name automatically with change_app_package_name package.');
//   } else {
//     print('✅ Android package name changed successfully\n');
//   }
//   if (firebaseProjectId.isNotEmpty) {
//     print('🔗 Running flutterfire configure to update firebase_options.dart (auto-overwrite)...');
//     ec = await runCmd('flutterfire', ['configure', '--project=$firebaseProjectId', '--platforms=android', '--yes']);
//     if (ec != 0) {
//       print('⚠️ flutterfire configure failed or is not installed. You can run it manually: flutterfire configure --project=$firebaseProjectId --platforms=android --yes');
//     } else {
//       print('✅ firebase_options.dart auto-updated without prompts.');
//     }
//   }
//   print('\n🧹 Running flutter clean...');
//   await runCmd('flutter', ['clean']);
//   await runCmd('flutter', ['pub', 'get']);
//   print('\n🔨 Building APK...');
//   final apkEc = await runCmd('flutter', ['build', 'apk', '--release']);
//   if (apkEc == 0) {
//     print('✅ APK built successfully! Location: build/app/outputs/flutter-apk/app-release.apk');
//   } else {
//     print('⚠️ APK build failed. Check errors above.');
//   }
//   print('\n🔨 Building AAB...');
//   final aabEc = await runCmd('flutter', ['build', 'appbundle', '--release']);
//   if (aabEc == 0) {
//     print('✅ AAB built successfully! Location: build/app/outputs/bundle/release/app-release.aab');
//   } else {
//     print('⚠️ AAB build failed. Check errors above.');
//   }
//   if (firebaseProjectId.isNotEmpty && appId != null) {
//     await uploadToFirebaseDistribution(firebaseProjectId, appId, TESTERS); // Use hardcoded testers
//   } else {
//     print('⚠️ No appId for distribution. Skipping upload.');
//   }
//   print('\n🎉 Setup & Build Complete!');
//   print('📋 Verify changes in:');
//   print(' • android/app/build.gradle');
//   print(' • android/app/src/main/AndroidManifest.xml');
//   print(' • android/app/google-services.json');
//   print(' • pubspec.yaml');
//   print(' • lib/ imports updated');
//   print(' • firebase_options.dart (auto-overwritten)');
//   print(' • APK: build/app/outputs/flutter-apk/app-release.apk');
//   print(' • AAB: build/app/outputs/bundle/release/app-release.aab\n');
//   print('✅ Done! You can now install or upload the builds.');
// }