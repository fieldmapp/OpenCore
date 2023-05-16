import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// todo, add indicator off signal quality edge,
// 3g, 5g ..., and only sync changes on good signal quality

class ConnectivityService {
  final List<String> connectedServices;
  late final Connectivity _connectivity;
  ConnectivityService({required this.connectedServices}) {
    _connectivity = Connectivity();
  }

  Future<bool> hasNetwork() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    switch (connectivityResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        return true;
      default:
        return false;
    }
  }

  Future<bool> isServiceReachable(String serviceName) async {
    try {
      final result = await InternetAddress.lookup(serviceName)
          .timeout(const Duration(seconds: 10));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<List<String>> allServicesReachable() async {
    final List<String> notConnected = [];
    for (final service in connectedServices) {
      if (!await isServiceReachable(service)) {
        notConnected.add(service);
      }
    }
    return notConnected;
  }

  Stream<ConnectivityResult> listenToConnectionChanges() {
    return _connectivity.onConnectivityChanged;
  }

  SnackBar getSnackbarForEvent(ConnectivityResult event) {
    var content = "";
    var color = Colors.red;
    Duration duration = const Duration(seconds: 3);
    switch (event) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        content = "Online";
        color = Colors.green;
        break;
      default:
        content = "offline";
        color = Colors.red;
        duration = const Duration(seconds: 4);
        break;
    }
    return SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      backgroundColor: color,
      padding: const EdgeInsets.all(4),
      behavior: SnackBarBehavior.fixed,
      duration: duration,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
    );
  }

  SnackBar getOfflineIndicator() {
    return const SnackBar(
      content: Text(
        "",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 1, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(2),
      behavior: SnackBarBehavior.fixed,
      duration: Duration(days: 3),
    );
  }

  void indicateConnectionChanges(
      {required GlobalKey<ScaffoldMessengerState> scaffoldKey}) {
    listenToConnectionChanges().listen((event) {
      scaffoldKey.currentState?.clearSnackBars();
      scaffoldKey.currentState?.showSnackBar(getSnackbarForEvent(event));
      if (event == ConnectivityResult.none) {
        scaffoldKey.currentState?.showSnackBar(getOfflineIndicator());
      }
    });
  }
}
