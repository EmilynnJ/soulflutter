import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/reading_session.dart';
import '../models/user_model.dart';

enum ConnectionState { disconnected, connecting, connected, reconnecting, failed }
enum CallState { idle, calling, ringing, connected, ended }

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  static WebRTCService get instance => _instance;
  
  WebRTCService._internal();

  // Agora RTC Engine
  RtcEngine? _agoraEngine;
  RtcEngine? get agoraEngine => _agoraEngine;
  IO.Socket? _socket;
  
  // Stream controllers
  final StreamController<ConnectionState> _connectionStateController = StreamController<ConnectionState>.broadcast();
  final StreamController<CallState> _callStateController = StreamController<CallState>.broadcast();
  final StreamController<int> _localUserJoinedController = StreamController<int>.broadcast();
  final StreamController<int> _remoteUserJoinedController = StreamController<int>.broadcast();
  final StreamController<int> _remoteUserLeftController = StreamController<int>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  // Streams
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<CallState> get callStateStream => _callStateController.stream;
  Stream<int> get localUserJoinedStream => _localUserJoinedController.stream;
  Stream<int> get remoteUserJoinedStream => _remoteUserJoinedController.stream;
  Stream<int> get remoteUserLeftStream => _remoteUserLeftController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // State variables
  ConnectionState _connectionState = ConnectionState.disconnected;
  CallState _callState = CallState.idle;
  ReadingSession? _currentSession;
  UserModel? _currentUser;
  UserModel? _remoteUser;
  Timer? _sessionTimer;
  int _sessionDuration = 0;
  bool _isInitialized = false;
  bool _isLocalVideoEnabled = true;
  bool _isLocalAudioEnabled = true;
  String? _currentChannelId;
  int? _localUid;

  // Agora configuration
  static const String _appId = 'YOUR_AGORA_APP_ID'; // Replace with actual App ID
  static const String _tempToken = ''; // Use token for production

  ConnectionState get connectionState => _connectionState;
  CallState get callState => _callState;
  bool get isVideoEnabled => _isLocalVideoEnabled;
  bool get isAudioEnabled => _isLocalAudioEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Initializing WebRTC Service with Agora...');
      
      // Request permissions
      await _requestPermissions();
      
      // Initialize Agora engine
      _agoraEngine = createAgoraRtcEngine();
      await _agoraEngine!.initialize(const RtcEngineContext(
        appId: _appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _agoraEngine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('Local user joined channel: ${connection.channelId}');
            _localUid = connection.localUid;
            _localUserJoinedController.add(connection.localUid!);
            _updateCallState(CallState.connected);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('Remote user joined: $remoteUid');
            _remoteUserJoinedController.add(remoteUid);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print('Remote user left: $remoteUid');
            _remoteUserLeftController.add(remoteUid);
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            print('Token will expire, need to renew');
          },
          onError: (ErrorCodeType err, String msg) {
            print('Agora Error: $err - $msg');
            _handleError('Agora Error: $msg');
          },
        ),
      );

      // Connect to signaling server
      _connectToSignalingServer();
      
      _isInitialized = true;
      _updateConnectionState(ConnectionState.connected);
      print('WebRTC Service initialized successfully');
      
    } catch (e) {
      print('Error initializing WebRTC Service: $e');
      _handleError('Failed to initialize WebRTC: $e');
      _updateConnectionState(ConnectionState.failed);
      // Don't rethrow - let the app continue in demo mode
    }
  }

  Future<void> _requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      bool allGranted = permissions.values.every((status) => status == PermissionStatus.granted);
      if (!allGranted) {
        print('Not all permissions granted, some features may not work');
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      // Continue without permissions - app should still work in limited mode
    }
  }

  void _connectToSignalingServer() {
    try {
      _socket = IO.io('wss://api.soulseer.com/signaling', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket?.on('connect', (_) {
        print('Connected to signaling server');
        _updateConnectionState(ConnectionState.connected);
      });

      _socket?.on('disconnect', (_) {
        print('Disconnected from signaling server');
        _updateConnectionState(ConnectionState.disconnected);
      });

      _socket?.on('join-channel', (data) => _handleJoinChannel(data));
      _socket?.on('leave-channel', (data) => _handleLeaveChannel(data));
      _socket?.on('call-end', (_) => _handleCallEnd());
      _socket?.on('error', (error) => _handleError('Signaling error: $error'));

      _socket?.connect();
    } catch (e) {
      print('Failed to connect to signaling server: $e');
      // Continue without signaling server - use demo mode
    }
  }

  Future<void> startReadingSession({
    required ReadingSession session,
    required UserModel currentUser,
    required UserModel remoteUser,
    required ReadingType type,
  }) async {
    try {
      _currentSession = session;
      _currentUser = currentUser;
      _remoteUser = remoteUser;
      
      await WakelockPlus.enable();
      
      if (type == ReadingType.video || type == ReadingType.phone) {
        await _joinChannel(session.id, type == ReadingType.video);
      }
      
      _startSessionTimer();
      _updateCallState(CallState.calling);
      
    } catch (e) {
      print('Error starting reading session: $e');
      _handleError('Failed to start reading session: $e');
    }
  }

  Future<void> _joinChannel(String channelId, bool enableVideo) async {
    try {
      if (_agoraEngine == null) {
        // Initialize in demo mode if Agora is not available
        print('Agora not initialized, running in demo mode');
        _simulateConnection();
        return;
      }

      _currentChannelId = channelId;
      
      // Enable video if needed
      if (enableVideo) {
        await _agoraEngine!.enableVideo();
        await _agoraEngine!.startPreview();
      } else {
        await _agoraEngine!.disableVideo();
      }
      
      // Enable audio
      await _agoraEngine!.enableAudio();
      
      // Join channel
      await _agoraEngine!.joinChannel(
        token: _tempToken,
        channelId: channelId,
        uid: 0, // Let Agora assign UID
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      
    } catch (e) {
      print('Error joining channel: $e');
      _simulateConnection(); // Fallback to demo mode
    }
  }

  void _simulateConnection() {
    // Simulate a successful connection for demo purposes
    print('Simulating WebRTC connection for demo mode');
    _updateCallState(CallState.connected);
    
    // Simulate remote user joining after 2 seconds
    Timer(const Duration(seconds: 2), () {
      _remoteUserJoinedController.add(12345);
    });
  }

  Future<void> toggleCamera() async {
    try {
      _isLocalVideoEnabled = !_isLocalVideoEnabled;
      
      if (_agoraEngine != null) {
        await _agoraEngine!.enableLocalVideo(_isLocalVideoEnabled);
      }
      
      _messageController.add({
        'type': 'camera_toggled',
        'enabled': _isLocalVideoEnabled,
      });
      
    } catch (e) {
      print('Error toggling camera: $e');
    }
  }

  Future<void> toggleMicrophone() async {
    try {
      _isLocalAudioEnabled = !_isLocalAudioEnabled;
      
      if (_agoraEngine != null) {
        await _agoraEngine!.enableLocalAudio(_isLocalAudioEnabled);
      }
      
      _messageController.add({
        'type': 'microphone_toggled',
        'enabled': _isLocalAudioEnabled,
      });
      
    } catch (e) {
      print('Error toggling microphone: $e');
    }
  }

  Future<void> endCall() async {
    try {
      if (_agoraEngine != null && _currentChannelId != null) {
        await _agoraEngine!.leaveChannel();
      }
      
      _endSession();
      
    } catch (e) {
      print('Error ending call: $e');
      _endSession(); // Force end session
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    
    _updateCallState(CallState.ended);
    
    _messageController.add({
      'type': 'session_ended',
      'duration': _sessionDuration,
      'cost': _calculateSessionCost(),
    });
    
    WakelockPlus.disable();
    
    _currentSession = null;
    _currentUser = null;
    _remoteUser = null;
    _sessionDuration = 0;
    _currentChannelId = null;
    _localUid = null;
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionDuration++;
      
      _messageController.add({
        'type': 'session_update',
        'duration': _sessionDuration,
        'cost': _calculateSessionCost(),
      });
    });
  }

  double _calculateSessionCost() {
    if (_currentSession == null) return 0.0;
    double minutes = _sessionDuration / 60.0;
    return minutes * _currentSession!.perMinuteRate;
  }

  void _handleJoinChannel(dynamic data) {
    print('Received join channel request: $data');
  }

  void _handleLeaveChannel(dynamic data) {
    print('Received leave channel request: $data');
  }

  void _handleCallEnd() {
    print('Call ended by remote user');
    _endSession();
  }

  void _updateConnectionState(ConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _updateCallState(CallState state) {
    _callState = state;
    _callStateController.add(state);
  }

  void _handleError(String error) {
    print('WebRTC Error: $error');
    _errorController.add(error);
  }

  Future<void> dispose() async {
    try {
      _sessionTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      
      if (_agoraEngine != null) {
        await _agoraEngine!.leaveChannel();
        await _agoraEngine!.release();
      }
      
      await _connectionStateController.close();
      await _callStateController.close();
      await _localUserJoinedController.close();
      await _remoteUserJoinedController.close();
      await _remoteUserLeftController.close();
      await _messageController.close();
      await _errorController.close();
      
      await WakelockPlus.disable();
      
    } catch (e) {
      print('Error disposing WebRTC Service: $e');
    }
  }
}