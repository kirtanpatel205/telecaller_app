import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:telecaller_app/core/services/internetcheck.dart';
import 'dart:ui';

class SocketController extends GetxController with WidgetsBindingObserver {
  static bool isBackground = false;
  static ServiceInstance? backgroundServiceInstance;

  IO.Socket? socket;
  RxBool isConnected = false.obs;
  RxString connectionStatus = 'Disconnected'.obs;
  RxString socketId = ''.obs;

  final NetworkService _networkService = Get.find<NetworkService>();
  StreamSubscription? _connectivitySubscription;

  void broadcastStatus() {
    final statusData = {
      'isConnected': isConnected.value,
      'connectionStatus': connectionStatus.value,
      'socketId': socketId.value,
    };

    if (isBackground) {
      if (backgroundServiceInstance != null) {
        // Only the Master background isolate (Foreground Service) broadcasts to UI
        backgroundServiceInstance!.invoke('socket_status', statusData);
      } else {
        // Satellite isolates (like FCM) should not overwrite the Master status in the UI
        print('📡 [Socket-Satellite] Isolate Status: ${connectionStatus.value}');
      }
    }
  }

  void _proxyEmit(String event, Map<String, dynamic> data) {
    if (isBackground) {
      if (backgroundServiceInstance != null) {
        // I am the MASTER isolate (Foreground Service)
        socket?.emit(event, data);
      } else {
        // I am a SATELLITE isolate (FCM handler etc.)
        // Priority 1: Proxy to the Master isolate for high-reliability emission
        final SendPort? masterPort = IsolateNameServer.lookupPortByName('socket_master_port');
        if (masterPort != null) {
          print('📤 [Socket-Satellite] Proxying $event to Master via SendPort');
          masterPort.send({'event': event, 'data': data});
        } else {
          // Fallback: Try to emit directly if no master is found
          print('📤 [Socket-Satellite] No Master found. Emitting directly: $event');
          socket?.emit(event, data);
        }
      }
    } else {
      // UI Mode: Always proxy via the background service bus
      FlutterBackgroundService().invoke('socket_emit', {
        'event': event,
        'data': data,
      });
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (isBackground) {
      _initBackgroundMode();
    } else {
      _initUiMode();
    }
  }

  void _initBackgroundMode() {
    print('⚙️ [Socket] Initializing in BACKGROUND mode (Master - Isolate: ${Isolate.current.debugName})');
    
    // Listen to network changes
    _connectivitySubscription = _networkService.isOnline.listen((isOnline) {
      if (isOnline) {
        print('🌐 [Socket-BG] Internet restored. Ensuring connection...');
        ensureConnected();
      } else {
        print('🌐 [Socket-BG] Internet lost.');
        connectionStatus.value = 'No Internet';
        broadcastStatus();
      }
    });

    // Handle hub status requests from other isolates
    FlutterBackgroundService().on('get_socket_status').listen((_) {
      print('📥 [Socket-BG] Received hub status request');
      broadcastStatus();
    });

    initSocket();
  }

  void _initUiMode() {
    print('🎨 [Socket] Initializing in UI mode (Proxy)');
    WidgetsBinding.instance.addObserver(this);

    // Listen to status updates from background service
    FlutterBackgroundService().on('socket_status').listen((event) {
      if (event != null) {
        isConnected.value = event['isConnected'] ?? false;
        connectionStatus.value = event['connectionStatus'] ?? 'Unknown';
        socketId.value = event['socketId'] ?? '';
      }
    });

    // Initial status request
    FlutterBackgroundService().invoke('get_socket_status');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isBackground) return; // Background isolate doesn't care about UI lifecycle

    developer.log('📱 [Socket-UI] App Lifecycle State: $state');
    if (state == AppLifecycleState.resumed) {
      print('📱 [Socket-UI] App resumed. Requesting status from background...');
      FlutterBackgroundService().invoke('ensure_socket_connected');
    }
  }

  Future<void> ensureConnected() async {
    if (!isBackground) {
      FlutterBackgroundService().invoke('ensure_socket_connected');
      return;
    }

    if (isConnected.value && socket != null && socket!.connected) {
      broadcastStatus();
      return;
    }
    
    if (!_networkService.isOnline.value) {
      print('⚠️ [Socket-BG] Cannot connect: No internet.');
      return;
    }

    print('🔄 [Socket-BG] ensureConnected triggered.');
    await initSocket();
  }

  // ================= INIT =================
  Future<void> initSocket() async {
    if (!isBackground) return;

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
    if (isBackground) {
      socket?.disconnect();
      socket?.dispose();
    }
    socket = null;

    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    socketId.value = '';

    if (isBackground) {
      developer.log('🔌 Socket disconnected (Master)');
      broadcastStatus();
    }
  }

  // ================= CONNECT =================
  void connectWithToken(String token) {
    if (!isBackground) return;
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
            .setTransports(['websocket', 'polling']) // Allow polling fallback
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
        broadcastStatus();
      });

      socket!.onDisconnect((_) {
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        socketId.value = '';

        print('❌ Socket Disconnected. Will attempt to reconnect automatically...');
        broadcastStatus();
      });

      socket!.onReconnect((_) {
        isConnected.value = true;
        connectionStatus.value = 'Connected';
        socketId.value = socket?.id ?? 'N/A';

        print('🔄 ✅ Socket Reconnected Successfully: ${socketId.value}');
        broadcastStatus();
      });

      socket!.onReconnectAttempt((attempt) {
        connectionStatus.value = 'Reconnecting...';
        print('🔄 Socket Reconnection Attempt: $attempt');
        broadcastStatus();
      });

      socket!.onConnectError((err) {
        connectionStatus.value = 'Connection Error';
        print('❌ Socket Connect Error: $err');
        broadcastStatus();
      });

      socket!.onError((err) {
        connectionStatus.value = 'Socket Error';
        print('❌ Socket Error: $err');
        broadcastStatus();
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

    _proxyEmit('telecaller:notification-received', data);
    print('📤 Notification Received emitted (proxy-aware): $data');
  }

  // ================= HEARTBEAT =================
  void emitHeartbeat() {
    if (isBackground && socket != null && isConnected.value) {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'active',
        'socketId': socketId.value,
      };
      socket!.emit('telecaller:heartbeat', data);
      developer.log('📤 Heartbeat sent');
    }
  }

  // ================= CALL START =================
  Future<void> emitCallStart({
    required String callSessionId,
    required String leadContactId,
    required String callId,
  }) async {
    if (callSessionId.isEmpty) {
      print('⚠️ [Socket] Skipping call-start: Empty callSessionId');
      return;
    }

    // Prevent duplicate emissions across isolates (FCM isolate vs BG service isolate)
    print('🔍 [Socket] Checking call-start de-dupe for session: $callSessionId');
    if (await Storage.isEventProcessed('call-start', callSessionId)) {
      print('⏳ [Socket] De-dupe HIT: Skipping duplicate call-start for session: $callSessionId');
      return;
    }
    await Storage.markEventProcessed('call-start', callSessionId);
    print('✅ [Socket] De-dupe MISS: Marking call-start processed for session: $callSessionId');

    final data = {
      'callSessionId': callSessionId,
      'leadContactId': leadContactId,
      'callId': callId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _proxyEmit('telecaller:call-start', data);
    print('📤 Call Start emitted (proxy-aware): $data');
  }

  // ================= CALL END =================
  Future<void> emitCallEnd({
    required String callSessionId,
    required String leadContactId,
    required int duration,
    required String answerType,
    required String answer,
  }) async {
    if (callSessionId.isEmpty) {
      print('⚠️ [Socket] Skipping call-end: Empty callSessionId');
      return;
    }

    // Prevent duplicate emissions across isolates
    print('🔍 [Socket] Checking call-end de-dupe for session: $callSessionId');
    if (await Storage.isEventProcessed('call-end', callSessionId)) {
      print('⏳ [Socket] De-dupe HIT: Skipping duplicate call-end for session: $callSessionId');
      return;
    }
    await Storage.markEventProcessed('call-end', callSessionId);
    print('✅ [Socket] De-dupe MISS: Marking call-end processed for session: $callSessionId');

    final data = {
      'callSessionId': callSessionId,
      'leadContactId': leadContactId,
      'duration': duration,
      'answerType': answerType,
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _proxyEmit('telecaller:call-end', data);
    print('📤 Call End emitted (proxy-aware): $data');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    disconnect();
    super.onClose();
  }
}
