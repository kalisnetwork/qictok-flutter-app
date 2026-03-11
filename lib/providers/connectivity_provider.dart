import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';

enum BackendStatus { checking, online, offline, noInternet }

class ConnectivityProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  BackendStatus _status = BackendStatus.checking;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  BackendStatus get status => _status;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _status = BackendStatus.noInternet;
        notifyListeners();
      } else {
        checkBackend();
      }
    });
    checkBackend();
  }

  Future<void> checkBackend() async {
    _status = BackendStatus.checking;
    notifyListeners();

    final isHealthy = await _api.checkConnection();
    if (isHealthy) {
      _status = BackendStatus.online;
    } else {
      _status = BackendStatus.offline;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
