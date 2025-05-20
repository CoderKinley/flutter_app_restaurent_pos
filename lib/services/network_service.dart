import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;
  String? _baseUrl;

  NetworkService({String? baseUrl}) {
    _baseUrl = baseUrl;
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results.first);
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      _controller.add(false);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    _controller.add(isConnected);
  }

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.first != ConnectivityResult.none;
  }

  Future<bool> isServerAvailable() async {
    if (_baseUrl == null) return false;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/fnb_bill_summary_legphel_eats'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('Server availability check failed: $e');
      return false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
