import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/helpers/storage.dart';

class SocketController extends GetxController {
  IO.Socket? socket;
  RxBool isConnected = false.obs;
  RxString connectionStatus = 'Disconnected'.obs;
  RxString socketId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initSocket();
  }

  // ================= INIT =================
  Future<void> initSocket() async {
    // 1. Get token with high-reliability (SharedPrefs + GetStorage)
    String? token = await Storage.getToken();

    // 2. Migration: Check for legacy JWT-as-key if new key is empty
    if (token == null || token.isEmpty) {
      const String legacyKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1YzFjODFlZGExNTUzNTZhZGQ3NDY0NyIsImlhdCI6MTcyMDA4MjAxNiwiZXhwIjoxNzIyNjc0MDE2fQ.EfqLVHpalTysNm-7YOhjvDD-K9ZZkZH92VxWfEaP7Hg';
      final String? legacyToken = Storage.getValue<String>(legacyKey);
      
      if (legacyToken != null && legacyToken.isNotEmpty) {
        print('🔄 [Socket] Migrating token from legacy key...');
        token = legacyToken;
        await Storage.saveToken(token);
        Storage.removeValue(legacyKey);
      }
    }

    if (token != null && token.isNotEmpty) {
      print('✅ [Socket] Token found (length: ${token.length}).');
      connectWithToken(token);
    } else {
      connectionStatus.value = 'Waiting for Token';
      print('⚠️ [Socket] No token found in storage.');
      
      try {
        final allKeys = GetStorage().getKeys();
        print('📦 [Socket] Available Storage Keys: $allKeys');
      } catch (e) {
        print('⚠️ [Socket] Error listing keys: $e');
      }
    }
  }

  Future<void> connect() async {
    if (isConnected.value) return;
    await initSocket();
  }

  void reconnect() {
    disconnect();
    Future.delayed(const Duration(seconds: 1), () => connect());
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;

    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    socketId.value = '';

    developer.log('🔌 Socket disconnected');
  }

  // ================= CONNECT =================
  void connectWithToken(String token) {
    try {
      if (socket != null && socket!.connected) {
        developer.log('📜 Already connected');
        return;
      }

      if (socket != null) {
        disconnect();
      }

      Uri uri = Uri.parse(AppConstants.BASE_SOCKET_URL);
      String baseUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri
          .port}' : ''}';
      String socketPath = '/socket.io';

      // If the URL has a path (e.g., /api), prepend it to the socket path
      if (uri.path.isNotEmpty && uri.path != '/') {
        String path = uri.path;
        if (path.endsWith('/')) {
          path = path.substring(0, path.length - 1);
        }
        socketPath = '$path/socket.io';
      }

      if (kDebugMode || true) { // Always print in background for now
        print('🔌 Connecting to: $baseUrl');
        print('📂 Socket Path: $socketPath');
        print('🔑 Token length: ${token.length}');
      }

      connectionStatus.value = 'Connecting...';

      socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // websocket only
            .setPath(socketPath)
            .setQuery({'token': token})
            .enableForceNew()
            .enableAutoConnect()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(5000)
            .build(),
      );

      socket!.onConnect((_) {
        isConnected.value = true;
        connectionStatus.value = 'Connected';
        socketId.value = socket?.id ?? 'N/A';

        print('✅ Socket Connected: ${socketId.value}');
      });

      socket!.onDisconnect((_) {
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        socketId.value = '';

        print('❌ Socket Disconnected');
      });

      socket!.onConnectError((err) {
        connectionStatus.value = 'Connection Error';
        print('❌ Socket Connect Error: $err');
      });

      socket!.onError((err) {
        connectionStatus.value = 'Socket Error';
        print('❌ Socket Error: $err');
      });
    } catch (e) {
      connectionStatus.value = 'Error';
      print('❌ Socket Initialization Error: $e');
    }
  }

  // ================= NOTIFICATION RECEIVED =================
  void emitNotificationReceived({
    required String? leadContactId,
    required String? callSessionId,
    required String? phoneNumber,
  }) {
    if (socket == null || !isConnected.value) {
      print(
          '⚠️ Cannot emit notification-received: Not connected. Attempting reconnect...');
      connect();
      if (socket == null) return;
    }

    final data = {
      'leadContactId': leadContactId,
      'callSessionId': callSessionId,
      'phoneNumber': phoneNumber,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'TELECALLER_NOTIFICATION_RECEIVED',
    };

    socket!.emit('telecaller:notification-received', data);
    print('📤 Notification Received emitted: $data');
  }

  // ================= HEARTBEAT =================
  void emitHeartbeat() {
    if (socket != null && isConnected.value) {
      socket!.emit('telecaller:heartbeat', {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'active',
        'socketId': socketId.value,
      });

      developer.log('📤 Heartbeat sent');
    }
  }

  // ================= CALL START =================
  Future<void> emitCallStart({
    required String callSessionId,
    required String leadContactId,
    required String callId,
  }) async {
    final data = {
      'callSessionId': callSessionId,
      'leadContactId': leadContactId,
      'callId': callId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Ensure token is loaded for background emissions
    if (!isConnected.value) {
      print('ℹ️ Socket not connected for call-start. Forcing initSocket...');
      await initSocket();
    }

    int retries = 0;
    while (!isConnected.value && retries < 5) {
      print(
          '⚠️ Socket waiting for connection (call-start). Retry $retries...');
      await Future.delayed(Duration(seconds: 1));
      retries++;
    }

    if (socket != null && isConnected.value) {
      socket!.emit('telecaller:call-start', data);
      print('📤 Call Start emitted: $data');
    } else {
      print(
          '❌ FAILED to emit call-start: Socket not connected after retries. Data: $data');
    }
  }

  // ================= CALL END =================
  Future<void> emitCallEnd({
    required String callSessionId,
    required String leadContactId,
    required int duration,
    required String answerType,
    required String answer,
  }) async {
    final data = {
      'callSessionId': callSessionId,
      'leadContactId': leadContactId,
      'duration': duration,
      'answerType': answerType,
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Ensure token is loaded for background emissions
    if (!isConnected.value) {
      print('ℹ️ Socket not connected for call-end. Forcing initSocket...');
      await initSocket();
    }

    int retries = 0;
    while (!isConnected.value && retries < 5) {
      print(
          '⚠️ Socket waiting for connection (call-end). Retry $retries...');
      await Future.delayed(Duration(seconds: 1));
      retries++;
    }

    if (socket != null && isConnected.value) {
      socket!.emit('telecaller:call-end', data);
      print('📤 Call End emitted: $data');
    } else {
      print(
          '❌ FAILED to emit call-end: Socket not connected after retries. Data: $data');
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
