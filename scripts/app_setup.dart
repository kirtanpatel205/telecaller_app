import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

// Hardcoded Firebase constants
const String FIREBASE_PROJECT_ID = "dbm-telecaller";
const String FIREBASE_ANDROID_APP_ID =
    "1:626864530224:android:f6b51f7a782de4a55bdef5";
const List<String> TESTERS = ["patelkirtan526@gmail.com"];

// API-driven rebranding constants
const String BASE_API_URL = "https://api.digibulkmarketing.com";
const String GET_REBRANDING_APPS_API =
    "$BASE_API_URL/app/app-rebranding/processing";
const String BUILDER_TOKEN = "Wc3PBpXFLj";

Future<int> runCmd(
    String exe,
    List<String> args, {
      bool throwOnError = false,
    }) async {
  print('💻 Running: $exe ${args.join(' ')}');
  final process = await Process.start(exe, args, runInShell: true);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  final code = await process.exitCode;
  if (code != 0 && throwOnError) {
    throw Exception('Command failed: $exe ${args.join(' ')} (exit $code)');
  }
  return code;
}

Future<Map<String, dynamic>> runCmdCapture(
    String exe,
    List<String> args,
    ) async {
  print('💻 Running (capture): $exe ${args.join(' ')}');
  final result = await Process.run(exe, args, runInShell: true);
  return {
    'exitCode': result.exitCode,
    'stdout': result.stdout?.toString() ?? '',
    'stderr': result.stderr?.toString() ?? '',
  };
}

Never exitWith(String msg, [int code = 1]) {
  stderr.writeln('$msg');
  exit(code);
}

void ensureExists(String path) {
  if (!File(path).existsSync()) exitWith('Required file not found: $path');
}

Future<void> renameAndroidLabel(String filePath, String appName) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    print('⚠️ AndroidManifest.xml not found: $filePath');
    return;
  }
  final data = await file.readAsString();
  final document = XmlDocument.parse(data);
  final appElement =
  document.findAllElements('application').isEmpty
      ? null
      : document.findAllElements('application').first;
  if (appElement == null) {
    print('⚠️ No <application> tag found in $filePath');
    return;
  }
  appElement.setAttribute('android:label', appName);
  await file.writeAsString(document.toXmlString(pretty: true, indent: ' '));
  print('✅ AndroidManifest.xml label updated to "$appName"');
}

Future<String> readPubspecName() async {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) return '';
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().startsWith('name:')) {
      return line.split(':').last.trim();
    }
  }
  return '';
}

Future<void> updatePubspecName(String appName) async {
  print('📝 Updating pubspec.yaml name...');
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('⚠️ pubspec.yaml not found');
    return;
  }
  final lines = await file.readAsLines();
  final newName = appName.toLowerCase().replaceAll(' ', '_');
  final updated =
  lines.map((l) {
    if (l.trim().startsWith('name:')) return 'name: $newName';
    return l;
  }).toList();
  await file.writeAsString(updated.join('\n'));
  print('✅ pubspec.yaml name updated to "$newName"\n');
}

Future<void> updateGradleNamespace(String packageName) async {
  print('📝 Updating Gradle namespace and applicationId...');
  File gradleFile = File('android/app/build.gradle');
  bool isKts = false;
  if (!gradleFile.existsSync()) {
    gradleFile = File('android/app/build.gradle.kts');
    isKts = true;
    if (!gradleFile.existsSync()) {
      print('⚠️ build.gradle not found');
      return;
    }
  }
  String content = await gradleFile.readAsString();
  final namespaceRegex = RegExp(r'namespace\s*=\s*"[a-zA-Z0-9_.]+"');
  if (namespaceRegex.hasMatch(content)) {
    content = content.replaceAllMapped(
      namespaceRegex,
          (_) => 'namespace = "$packageName"',
    );
  } else {
    content = content.replaceFirst(
      'android {',
      'android {\n namespace = "$packageName"',
    );
  }
  final appIdRegex =
  isKts
      ? RegExp(r'applicationId\s*=\s*"[a-zA-Z0-9_.]+"')
      : RegExp(r'applicationId\s+"[a-zA-Z0-9_.]+"');
  if (appIdRegex.hasMatch(content)) {
    content = content.replaceAllMapped(
      appIdRegex,
          (_) =>
      isKts
          ? 'applicationId = "$packageName"'
          : 'applicationId "$packageName"',
    );
  }
  await gradleFile.writeAsString(content);
  print('✅ Gradle namespace and applicationId updated\n');
}

Future<void> updateDartImports(String oldPackage, String newPackage) async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('⚠️ lib directory not found');
    return;
  }
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (var file in dartFiles) {
    String content = await file.readAsString();
    if (content.contains('package:$oldPackage/')) {
      content = content.replaceAll(
        'package:$oldPackage/',
        'package:$newPackage/',
      );
      await file.writeAsString(content);
      print('✅ Updated imports in ${file.path}');
    }
  }
}

String escapeKotlinKeywords(String packageName) {
  final keywords = {
    'in',
    'as',
    'is',
    'val',
    'var',
    'fun',
    'object',
    'typealias',
    'class',
    'interface',
    'this',
    'super',
    'typeof',
    'package',
    'import',
    'return',
    'break',
    'continue',
    'throw',
    'try',
    'catch',
    'finally',
    'if',
    'else',
    'when',
    'while',
    'do',
    'for',
  };
  return packageName
      .split('.')
      .map((segment) {
    if (keywords.contains(segment)) {
      return '`$segment`';
    }
    return segment;
  })
      .join('.');
}

Future<void> updateKotlinPackageStructure(String packageName) async {
  print('🧩 Updating Kotlin package structure (renaming folders)...');
  final baseKotlin = Directory('android/app/src/main/kotlin');
  if (!baseKotlin.existsSync()) {
    print('⚠️ Kotlin directory not found.');
    return;
  }
  final allFiles = baseKotlin.listSync(recursive: true).whereType<File>();
  final kotlinFiles = allFiles.where((f) => f.path.endsWith('.kt')).toList();
  if (kotlinFiles.isEmpty) {
    print('⚠️ No Kotlin files found.');
    return;
  }
  final oldFile = kotlinFiles.first;
  final oldDir = Directory(p.dirname(oldFile.path));
  final oldRelativePath = p.relative(oldDir.path, from: baseKotlin.path);
  final newRelativePath = packageName.replaceAll('.', '/');
  if (oldRelativePath == newRelativePath) {
    print('✅ Kotlin folder already matches package name.');
  } else {
    final newDirPath = p.join(baseKotlin.path, newRelativePath);
    final newDirParent = Directory(p.dirname(newDirPath));
    if (!newDirParent.existsSync()) {
      newDirParent.createSync(recursive: true);
    }
    print('📁 Renaming folder:\n $oldRelativePath → $newRelativePath');
    try {
      oldDir.renameSync(newDirPath);
    } catch (e) {
      print('⚠️ Could not rename kotlin folder automatically: $e');
    }
  }
  final updatedFiles = Directory(p.join(baseKotlin.path, newRelativePath))
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.kt'));
  final escapedPackageName = escapeKotlinKeywords(packageName);
  for (final file in updatedFiles) {
    String content = await file.readAsString();
    final pkgRegex = RegExp(r'^package\s+[`a-zA-Z0-9_.]+', multiLine: true);
    content = content.replaceAllMapped(
      pkgRegex,
          (_) => 'package $escapedPackageName',
    );
    await file.writeAsString(content);
    print('✅ Updated package in ${p.basename(file.path)}');
  }
  print('✅ Kotlin folder renamed successfully.\n');
}

Future<String> prepareAppIcon(String logoPath) async {
  print('🎨 Preparing balanced 1024x1024 app icon...');
  final bytes = await File(logoPath).readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) exitWith('Could not decode image: $logoPath');
  const int canvasSize = 1024;
  const int paddingPx = 150;
  final availableSize = canvasSize - (2 * paddingPx);
  int targetWidth, targetHeight;
  if (original.width >= original.height) {
    targetWidth = availableSize;
    targetHeight = (original.height * availableSize / original.width).toInt();
  } else {
    targetHeight = availableSize;
    targetWidth = (original.width * availableSize / original.height).toInt();
  }
  final resized = img.copyResize(
    original,
    width: targetWidth,
    height: targetHeight,
  );
  final background = img.Image(width: canvasSize, height: canvasSize);
  final offsetX = (canvasSize - targetWidth) ~/ 2;
  final offsetY = (canvasSize - targetHeight) ~/ 2;
  img.compositeImage(background, resized, dstX: offsetX, dstY: offsetY);
  const outputPath = 'assets/images/processed_app_icon.png';
  final outputFile = File(outputPath);
  outputFile.createSync(recursive: true);
  outputFile.writeAsBytesSync(img.encodePng(background));
  print('✅ Centered icon with ${paddingPx}px padding → $outputPath');
  return outputPath;
}

Future<void> updateGoogleServiceJsonPackage(String packageName) async {
  final file = File('android/app/google-services.json');
  print('\n🔥 Updating google-services.json package names...');
  if (!file.existsSync()) {
    print('⚠️ google-services.json not found in android/app/');
    return;
  }
  final Map<String, dynamic> jsonContent = jsonDecode(
    await file.readAsString(),
  );
  if (jsonContent['client'] is List) {
    for (final client in jsonContent['client']) {
      final clientInfo = client['client_info']?['android_client_info'];
      if (clientInfo != null && clientInfo['package_name'] != null) {
        clientInfo['package_name'] = packageName;
      }
      if (client['oauth_client'] is List) {
        for (final oauth in client['oauth_client']) {
          final androidInfo = oauth['android_info'];
          if (androidInfo != null && androidInfo['package_name'] != null) {
            androidInfo['package_name'] = packageName;
          }
        }
      }
    }
  }
  await file.writeAsString(
    const JsonEncoder.withIndent(' ').convert(jsonContent),
  );
  print(
    '✅ All package names in google-services.json updated to → $packageName\n',
  );
}

Future<void> updateAppConstantsLogo(String processedLogo) async {
  const constantsPath = 'lib/constants/app_constants.dart';
  final constantsFile = File(constantsPath);
  if (!constantsFile.existsSync()) {
    print('⚠️ AppConstants file not found at $constantsPath\n');
    return;
  }
  print('🔍 Updating APPLOGO in AppConstants...');
  String content = await constantsFile.readAsString();
  final lines = content.split('\n');
  bool found = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('APPLOGO') && lines[i].contains('=')) {
      lines[i] = ' static const String APPLOGO = "$processedLogo";';
      found = true;
      break;
    }
  }
  if (found) {
    await constantsFile.writeAsString(lines.join('\n'));
    print('✅ APPLOGO updated to → $processedLogo\n');
  } else {
    print('ℹ️ No APPLOGO constant found in AppConstants.\n');
  }
}

Future<String> resolveAppIcon(String iconPathOrUrl, String appName) async {
  if (iconPathOrUrl.startsWith('http://') ||
      iconPathOrUrl.startsWith('https://')) {
    return await downloadAppIcon(iconPathOrUrl, appName);
  }
  return iconPathOrUrl;
}

Future<void> updateBaseUrl(String apiUrl) async {
  const constantsPath = 'lib/constants/app_constants.dart';
  final constantsFile = File(constantsPath);
  if (!constantsFile.existsSync()) {
    print('⚠️ AppConstants file not found at $constantsPath\n');
    return;
  }
  print('🔍 Updating BASE_URL in AppConstants...');
  String content = await constantsFile.readAsString();

  String baseUrl = apiUrl;
  if (baseUrl.endsWith('/api/')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 5);
  } else if (baseUrl.endsWith('/api')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 4);
  } else if (baseUrl.endsWith('/')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 1);
  }

  final baseUrlRegex = RegExp(
    r'static\s+const\s+String\s+BASE_URL\s*=\s*"[^"]*";',
  );
  if (baseUrlRegex.hasMatch(content)) {
    content = content.replaceAll(
      baseUrlRegex,
      'static const String BASE_URL = "$baseUrl";',
    );
    await constantsFile.writeAsString(content);
    print('✅ BASE_URL updated to → \$baseUrl\\n');
  } else {
    print('⚠️ No BASE_URL constant found in AppConstants.\n');
  }
}

Future<void> updateAppName(String appName) async {
  const constantsPath = 'lib/constants/app_constants.dart';
  final constantsFile = File(constantsPath);
  if (!constantsFile.existsSync()) {
    print('⚠️ AppConstants file not found at $constantsPath\n');
    return;
  }
  print('🔍 Updating APP_NAME in AppConstants...');
  String content = await constantsFile.readAsString();

  final appNameRegex = RegExp(
    r'static\s+const\s+String\s+APP_NAME\s*=\s*"[^"]*";',
  );
  if (appNameRegex.hasMatch(content)) {
    content = content.replaceAll(
      appNameRegex,
      'static const String APP_NAME = "$appName";',
    );
  } else {
    content = content.replaceFirst(
      'class AppConstants {',
      'class AppConstants {\n  static const String APP_NAME = "$appName";',
    );
  }
  await constantsFile.writeAsString(content);
  print('✅ APP_NAME updated to → $appName\n');
}

Future<bool> checkFirebaseAuth() async {
  final res = await runCmdCapture('firebase', ['projects:list', '--json']);
  if (res['exitCode'] != 0) {
    if (res['stderr'].toString().contains('not signed in') ||
        res['stderr'].toString().contains('authentication')) {
      print('⚠️ Firebase CLI not authenticated. Running firebase login...');
      final loginCode = await runCmd('firebase', [
        'login',
      ], throwOnError: false);
      if (loginCode != 0) {
        print(
          '❌ Firebase login failed. Please run "firebase login" manually in terminal.',
        );
        return false;
      }
      print('✅ Firebase login successful.');
      return true;
    } else {
      print('⚠️ Firebase projects:list failed: ${res['stderr']}');
      return false;
    }
  }
  return true;
}

Future<bool> downloadSdkConfig(String projectId, String appId) async {
  final outfile = 'android/app/google-services.json';
  final tempfile = 'android/app/google-services-temp.json';

  print(
    '💻 Running: firebase apps:sdkconfig ANDROID $appId --project $projectId --out $tempfile',
  );
  final code = await runCmd('firebase', [
    'apps:sdkconfig',
    'ANDROID',
    appId,
    '--project',
    projectId,
    '--out',
    outfile,
  ]);
  if (code == 0) {
    print('✅ Downloaded google-services.json → $outfile');
    return true;
  } else {
    print(
      '⚠️ Could not download google-services.json via firebase apps:sdkconfig',
    );
    return false;
  }
}

Future<void> uploadToFirebaseDistribution(
    String firebaseProjectId,
    String androidAppId,
    List<String> testers,
    ) async {
  print("\n🚀 Uploading to Firebase App Distribution...");
  final apkPath = "build/app/outputs/flutter-apk/app-release.apk";
  if (!File(apkPath).existsSync()) {
    print(" APK not found: $apkPath");
    return;
  }
  final result = await Process.run("firebase", [
    "appdistribution:distribute",
    apkPath,
    "--app=$androidAppId",
    "--project=$firebaseProjectId",
    "--testers=${testers.join(",")}",
    "--release-notes=Automated build from app_setup.dart",
  ], runInShell: true);
  if (result.stderr.toString().isNotEmpty &&
      !result.stderr.toString().contains("error")) {
    print("⚠ Some warnings:");
    print(result.stderr);
  }
  if (result.stdout.toString().contains("uploaded")) {
    print("🎉 Upload Successful!");
  } else {
    print(result.stdout);
  }
}

Future<List<Map<String, dynamic>>> fetchRebrandingApps() async {
  print("🌐 Fetching rebranding apps from API...");
  final client = HttpClient();
  try {
    final uri = Uri.parse(GET_REBRANDING_APPS_API);
    final request = await client.postUrl(uri);
    request.headers.set('Authorization', 'Bearer $BUILDER_TOKEN');
    request.headers.set('Content-Type', 'application/json');

    final bodyObj = {
      "panelId": "",
      "userId": "",
      "appType": "telecaller",
      "status": "",
      "page": 0,
      "limit": 20,
    };
    request.write(jsonEncode(bodyObj));

    final response = await request.close();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);
      if (data["status"] == true && data["data"] is List) {
        return List<Map<String, dynamic>>.from(data["data"]);
      } else {
        print(
          "❌ API failed to return data. Status field is false or data is not a list.",
        );
        return [];
      }
    } else {
      print("❌ API failed with status code: ${response.statusCode}");
      final responseBody = await response.transform(utf8.decoder).join();
      print("Response: $responseBody");
      return [];
    }
  } catch (e) {
    print("❌ API connection failed: $e");
    return [];
  } finally {
    client.close();
  }
}

Future<String> downloadAppIcon(String url, String appName) async {
  print("🌐 Downloading remote app icon from $url...");
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode == 200) {
      final bytesBuilder = BytesBuilder();
      await for (var chunk in response) {
        bytesBuilder.add(chunk);
      }
      final bytes = bytesBuilder.takeBytes();

      // Decode the image to check dimensions
      final original = img.decodeImage(bytes);
      if (original == null) {
        exitWith('Could not decode downloaded image.');
      }

      List<int> outputBytes;
      if (original.width != 512 || original.height != 512) {
        print(
          '🎨 Image size is ${original.width}x${original.height}. Resizing to 512x512...',
        );
        final resized = img.copyResize(original, width: 512, height: 512);
        outputBytes = img.encodePng(resized);
      } else {
        outputBytes = bytes;
      }

      final cleanedAppName = appName.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9_]'),
        '_',
      );
      final savePath = 'assets/images/$cleanedAppName.png';
      File(savePath).createSync(recursive: true);
      File(savePath).writeAsBytesSync(outputBytes);
      print('✅ Downloaded and processed app icon saved to $savePath');
      return savePath;
    } else {
      exitWith(
        'Failed to download app icon. Status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    exitWith('Error downloading app icon: $e');
  } finally {
    client.close();
  }
}

Future<String?> uploadApk({
  required String rebrandId,
  required String apkPath,
}) async {
  print("📤 Uploading APK to server...");
  final file = File(apkPath);
  if (!file.existsSync()) {
    print("❌ APK file not found at $apkPath");
    return null;
  }

  final client = HttpClient();
  try {
    final uploadUrl = "$BASE_API_URL/app/app-rebranding/$rebrandId/apk";
    final uri = Uri.parse(uploadUrl);
    final request = await client.postUrl(uri);

    final boundary =
        "----DartHttpClientBoundary${DateTime.now().millisecondsSinceEpoch}";
    request.headers.set('Authorization', 'Bearer $BUILDER_TOKEN');
    request.headers.set(
      'Content-Type',
      'multipart/form-data; boundary=$boundary',
    );

    // Header part
    final filename = p.basename(apkPath);
    final header =
        "--$boundary\r\n"
        "Content-Disposition: form-data; name=\"apk\"; filename=\"$filename\"\r\n"
        "Content-Type: application/vnd.android.package-archive\r\n\r\n";
    final headerBytes = utf8.encode(header);

    // Footer part
    final footer = "\r\n--$boundary--\r\n";
    final footerBytes = utf8.encode(footer);

    final fileLength = await file.length();
    final totalLength = headerBytes.length + fileLength + footerBytes.length;
    request.contentLength = totalLength;

    request.add(headerBytes);
    await request.addStream(file.openRead());
    request.add(footerBytes);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print("Upload response code: ${response.statusCode}");
    print("Upload response body: $responseBody");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> resData = jsonDecode(responseBody);
      if (resData["status"] == true || resData["data"] != null) {
        final dataPart = resData["data"];
        String? downloadUrl;
        if (dataPart is Map) {
          downloadUrl =
              dataPart["downloadUrl"]?.toString() ??
                  dataPart["url"]?.toString();
        }
        downloadUrl ??=
            resData["downloadUrl"]?.toString() ?? resData["url"]?.toString();
        if (downloadUrl != null) {
          print("✅ APK uploaded successfully. URL: $downloadUrl");
          return downloadUrl;
        } else {
          print("⚠️ APK uploaded, but download URL not found in response.");
          return null;
        }
      } else {
        print(
          "❌ APK upload API failed: ${resData['message'] ?? 'Unknown error'}",
        );
        return null;
      }
    } else {
      print("❌ APK upload failed with status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("❌ Error uploading APK: $e");
    return null;
  } finally {
    client.close();
  }
}

Future<void> updateBuildInfo({
  required String rebrandId,
  required String firebaseProjectId,
  required String firebaseAppId,
  required String downloadUrl,
}) async {
  print("🔄 Updating build info on server...");
  final client = HttpClient();
  try {
    final updateUrl = "$BASE_API_URL/app/app-rebranding/$rebrandId/build";
    final uri = Uri.parse(updateUrl);
    final request = await client.putUrl(uri);
    request.headers.set('Authorization', 'Bearer $BUILDER_TOKEN');
    request.headers.set('Content-Type', 'application/json');

    final bodyObj = {
      "firebaseProjectId": firebaseProjectId,
      "firebaseAppId": firebaseAppId,
      "downloadUrl": downloadUrl,
    };
    request.write(jsonEncode(bodyObj));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print("Update build info response code: ${response.statusCode}");
    print("Update build info response body: $responseBody");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Build info updated successfully.");
    } else {
      print(
        "❌ Failed to update build info. Status code: ${response.statusCode}",
      );
    }
  } catch (e) {
    print("❌ Error updating build info: $e");
  } finally {
    client.close();
  }
}

Future<String?> getOrCreateFirebaseAppId(
    String projectId,
    String packageName,
    String appName,
    ) async {
  print(
    "🔍 Querying Firebase project '$projectId' for package name '$packageName'...",
  );
  final listRes = await runCmdCapture('firebase', [
    'apps:list',
    '--project',
    projectId,
    '--json',
  ]);
  if (listRes['exitCode'] == 0) {
    try {
      final stdoutStr = listRes['stdout'].toString();
      final jsonStartIndex = stdoutStr.indexOf('{');
      if (jsonStartIndex != -1) {
        final jsonContent = stdoutStr.substring(jsonStartIndex);
        final data = jsonDecode(jsonContent);
        if (data is Map && data['result'] is List) {
          final apps = data['result'] as List;
          for (final app in apps) {
            if (app is Map &&
                app['platform'] == 'ANDROID' &&
                (app['namespace'] == packageName ||
                    app['package_name'] == packageName)) {
              final foundId = app['appId']?.toString();
              if (foundId != null) {
                print("✅ Found existing Firebase App ID: $foundId");
                return foundId;
              }
            }
          }
        }
      }
    } catch (e) {
      print("⚠️ Error parsing firebase apps:list output: $e");
    }
  } else {
    print("⚠️ Failed to list firebase apps: ${listRes['stderr']}");
  }

  print("🆕 Firebase app not found for '$packageName'. Creating a new one...");
  final createRes = await runCmdCapture('firebase', [
    'apps:create',
    'ANDROID',
    appName,
    '--package-name',
    packageName,
    '--project',
    projectId,
    '--json',
  ]);

  if (createRes['exitCode'] == 0) {
    try {
      final stdoutStr = createRes['stdout'].toString();
      final jsonStartIndex = stdoutStr.indexOf('{');
      if (jsonStartIndex != -1) {
        final jsonContent = stdoutStr.substring(jsonStartIndex);
        final data = jsonDecode(jsonContent);
        if (data is Map && data['result'] != null) {
          final newAppId = data['result']['appId']?.toString();
          if (newAppId != null) {
            print("✅ Created new Firebase App ID: $newAppId");
            return newAppId;
          }
        }
      }
    } catch (e) {
      print("⚠️ Error parsing apps:create output: $e");
    }
  } else {
    print("❌ Failed to create Firebase app: ${createRes['stderr']}");
  }

  print("🔄 Refreshing Firebase apps list as fallback...");
  final listRes2 = await runCmdCapture('firebase', [
    'apps:list',
    '--project',
    projectId,
    '--json',
  ]);
  if (listRes2['exitCode'] == 0) {
    try {
      final stdoutStr = listRes2['stdout'].toString();
      final jsonStartIndex = stdoutStr.indexOf('{');
      if (jsonStartIndex != -1) {
        final jsonContent = stdoutStr.substring(jsonStartIndex);
        final data = jsonDecode(jsonContent);
        if (data is Map && data['result'] is List) {
          final apps = data['result'] as List;
          for (final app in apps) {
            if (app is Map &&
                app['platform'] == 'ANDROID' &&
                (app['namespace'] == packageName ||
                    app['package_name'] == packageName)) {
              final foundId = app['appId']?.toString();
              if (foundId != null) {
                print("✅ Found dynamically created Firebase App ID: $foundId");
                return foundId;
              }
            }
          }
        }
      }
    } catch (e) {
      print("⚠️ Fallback parse error: $e");
    }
  }
  return null;
}

Future<void> main() async {
  // 1. Fetch rebranding configurations from API
  final configs = await fetchRebrandingApps();
  if (configs.isEmpty) {
    exitWith('No rebranding apps found or API call failed.');
  }

  // 2. Display apps dynamically from API
  print('\n📱 Available Apps for Rebranding:');
  for (int i = 0; i < configs.length; i++) {
    final cfg = configs[i];
    print(' ${i + 1}. ${cfg['appName']} (${cfg['packageName']})');
  }

  // 3. Selection
  stdout.write('\n👉 Enter app number to rebrand (1-${configs.length}): ');
  final input = stdin.readLineSync();
  final index = int.tryParse(input ?? '') ?? -1;
  if (index < 1 || index > configs.length) exitWith('Invalid selection.');
  final config = configs[index - 1];

  // 4. Map configuration variables
  final rebrandId = config['_id']?.toString() ?? '';
  final appName = config['appName']?.toString() ?? '';
  final packageName = config['packageName']?.toString() ?? '';
  final logoPathRaw = config['appIcon']?.toString() ?? '';
  final firebaseProjectId = "dbm-telecaller";
  final dynamicAppId = await getOrCreateFirebaseAppId(
    firebaseProjectId,
    packageName,
    appName,
  );
  final firebaseAppId =
      dynamicAppId ?? "1:626864530224:android:f6b51f7a782de4a55bdef5";
  final apiUrl = config['apiUrl']?.toString() ?? '';

  if (rebrandId.isEmpty) {
    exitWith('rebrandId (_id) is missing in configuration.');
  }
  if (apiUrl.isEmpty) {
    exitWith('apiUrl is missing in configuration.');
  }
  if (appName.isEmpty || packageName.isEmpty || logoPathRaw.isEmpty) {
    exitWith(
      'Invalid configuration data (appName/packageName/appIcon is empty).',
    );
  }

  // 5. Generate full app icon URL
  String base = apiUrl;
  if (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  String path = logoPathRaw;
  if (path.startsWith('/')) {
    path = path.substring(1);
  }
  final fullIconUrl = "$base/$path";

  // 6. Download app icon
  final logoPath = await downloadAppIcon(fullIconUrl, appName);
  if (!File(logoPath).existsSync()) {
    exitWith('Logo file not found after download: $logoPath');
  }

  // 7. Rebrand print details
  print('\n🚀 Selected Configuration:');
  print(' 🏷️ App Name: $appName');
  print(' 📦 Package: $packageName');
  print(' 🖼️ Logo Path: $logoPath');
  print(' 🔑 Firebase Project: $firebaseProjectId');
  print(' 📱 Firebase App ID: $firebaseAppId\n');

  final processedLogo = await prepareAppIcon(logoPath);
  final iconsYaml = '''
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$processedLogo"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "$processedLogo"
  min_sdk_android: 21
  remove_alpha_ios: true
''';
  File('flutter_launcher_icons.yaml').writeAsStringSync(iconsYaml);
  print('✅ Created flutter_launcher_icons.yaml\n');

  await updateAppConstantsLogo(logoPath);

  var ec = await runCmd('flutter', ['pub', 'get']);
  if (ec != 0) exitWith('flutter pub get failed');

  ec = await runCmd('flutter', ['pub', 'run', 'flutter_launcher_icons']);
  if (ec != 0) {
    print('⚠️ flutter_launcher_icons failed. Continue anyway.');
  }

  final oldPackage = await readPubspecName();
  print('📦 Old package name detected: $oldPackage');

  await renameAndroidLabel('android/app/src/main/AndroidManifest.xml', appName);
  await updatePubspecName(appName);
  await updateGradleNamespace(packageName);
  await updateBaseUrl(apiUrl);
  await updateAppName(appName);

  final newPackage = appName.toLowerCase().replaceAll(' ', '_');
  await updateDartImports(oldPackage, newPackage);
  await updateKotlinPackageStructure(packageName);

  // 8. Firebase setup
  String? appId = firebaseAppId;
  if (firebaseProjectId.isEmpty || appId.isEmpty) {
    print(
      '⚠️ Firebase Project ID or App ID is empty. Skipping firebase configuration.',
    );
  } else {
    final fvCheck = await runCmdCapture('firebase', ['--version']);
    if (fvCheck['exitCode'] != 0) {
      print(
        '⚠️ Firebase CLI not found. Attempting to install via npm (requires npm).',
      );
      final npmRc = await runCmd('npm', ['install', '-g', 'firebase-tools']);
      if (npmRc != 0) {
        print(
          '❌ Could not install firebase-tools. Please install manually and re-run.',
        );
      }
    }
    final authOk = await checkFirebaseAuth();
    if (!authOk) {
      print('❌ Firebase authentication failed. Skipping Firebase automation.');
    } else {
      print('ℹ️ Using Firebase Android appId: $appId');
      final ok = await downloadSdkConfig(firebaseProjectId, appId);
      if (!ok) {
        print(
          '⚠️ apps:sdkconfig method failed. Trying fallback: apps:sdkconfig --json and write file manually.',
        );
        final res = await runCmdCapture('firebase', [
          'apps:sdkconfig',
          'ANDROID',
          appId,
          '--project',
          firebaseProjectId,
          '--json',
        ]);
        if (res['exitCode'] == 0) {
          try {
            final obj = jsonDecode(res['stdout']);
            String? fileContents;
            if (obj is Map) {
              if (obj['config'] != null) {
                fileContents = const JsonEncoder.withIndent(
                  ' ',
                ).convert(obj['config']);
              } else if (obj['result'] != null &&
                  obj['result']['fileContents'] != null) {
                fileContents = obj['result']['fileContents'];
              }
            }
            if (fileContents != null) {
              final outfile = 'android/app/google-services.json';
              await File(outfile).writeAsString(fileContents);
              print(
                '✅ Wrote google-services.json from sdkconfig JSON to $outfile',
              );
            } else {
              print('⚠️ Unexpected sdkconfig JSON format: ${res['stdout']}');
            }
          } catch (e) {
            print('⚠️ Could not parse sdkconfig JSON: $e');
          }
        } else {
          print('⚠️ apps:sdkconfig also failed: ${res['stderr']}');
        }
      }
    }
  }

  // ALWAYS update the package name in the existing google-services.json
  await updateGoogleServiceJsonPackage(packageName);

  print('🏷 Changing Android package structure (change_app_package_name) ...');
  ec = await runCmd('flutter', [
    'pub',
    'run',
    'change_app_package_name:main',
    packageName,
  ]);
  if (ec != 0) {
    print(
      '⚠️ Could not change Android package name automatically with change_app_package_name package.',
    );
  } else {
    print('✅ Android package name changed successfully\n');
  }

  if (firebaseProjectId.isNotEmpty) {
    print(
      '🔗 Running flutterfire configure to update firebase_options.dart (auto-overwrite)...',
    );
    ec = await runCmd('flutterfire', [
      'configure',
      '--project=$firebaseProjectId',
      '--platforms=android',
      '--yes',
    ]);
    if (ec != 0) {
      print(
        '⚠️ flutterfire configure failed or is not installed. You can run it manually: flutterfire configure --project=$firebaseProjectId --platforms=android --yes',
      );
    } else {
      print('✅ firebase_options.dart auto-updated without prompts.');
    }
  }

  print('\n🧹 Running flutter clean...');
  await runCmd('flutter', ['clean']);
  await runCmd('flutter', ['pub', 'get']);

  // 9. Build APK
  print('\n🔨 Building APK...');
  final apkEc = await runCmd('flutter', ['build', 'apk', '--release']);
  if (apkEc == 0) {
    print(
      '✅ APK built successfully! Location: build/app/outputs/flutter-apk/app-release.apk',
    );
  } else {
    print('⚠️ APK build failed. Check errors above.');
  }

  // 10. Build AAB
  print('\n🔨 Building AAB...');
  final aabEc = await runCmd('flutter', ['build', 'appbundle', '--release']);
  if (aabEc == 0) {
    print(
      '✅ AAB built successfully! Location: build/app/outputs/bundle/release/app-release.aab',
    );
  } else {
    print('⚠️ AAB build failed. Check errors above.');
  }

  // 11. Upload APK & Update build info
  String? downloadUrl;
  if (apkEc == 0) {
    downloadUrl = await uploadApk(
      rebrandId: rebrandId,
      apkPath: 'build/app/outputs/flutter-apk/app-release.apk',
    );
  } else {
    print('⚠️ Skipping APK upload because APK build failed.');
  }

  if (downloadUrl != null) {
    await updateBuildInfo(
      rebrandId: rebrandId,
      firebaseProjectId: firebaseProjectId,
      firebaseAppId: firebaseAppId,
      downloadUrl: downloadUrl,
    );
  } else {
    print(
      '⚠️ Skipping updateBuildInfo because APK upload did not return a valid download URL.',
    );
  }

  if (firebaseProjectId.isNotEmpty && appId != null && appId.isNotEmpty) {
    await uploadToFirebaseDistribution(firebaseProjectId, appId, TESTERS);
  } else {
    print(
      '⚠️ No appId or firebaseProjectId for distribution. Skipping upload.',
    );
  }

  print('\n🎉 Setup & Build Complete!');
  print('📋 Verify changes in:');
  print(' • android/app/build.gradle');
  print(' • android/app/src/main/AndroidManifest.xml');
  print(' • android/app/google-services.json');
  print(' • pubspec.yaml');
  print(' • lib/ imports updated');
  print(' • firebase_options.dart (auto-overwritten)');
  print(' • APK: build/app/outputs/flutter-apk/app-release.apk');
  print(' • AAB: build/app/outputs/bundle/release/app-release.aab\n');
  print('✅ Done! Rebranding and build pipelines completed automatically.');
}
