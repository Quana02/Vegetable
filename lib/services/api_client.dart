import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';

import '../models/cart_item.dart';
import '../models/user_account.dart';
import '../models/vegetable.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  HubConnection? _hubConnection;
  
  final realtimeUpdateNotifier = ValueNotifier<int>(0);

  Future<void> startRealtimeConnection() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl('$baseUrl/hubs/app')
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('VegetablesUpdated', (_) {
      realtimeUpdateNotifier.value++;
    });

    try {
      await _hubConnection!.start();
    } catch (e) {
      debugPrint('SignalR Error: $e');
    }
  }

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5226';
    }
    return 'http://localhost:5226';
  }

  static const _headers = {'Content-Type': 'application/json'};

  Future<UserAccount> demoLogin(UserRole role) async {
    final response = await _client.post(
      _uri('/api/auth/demo-login'),
      headers: _headers,
      body: jsonEncode({'role': role.name}),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<UserAccount> login(String email, String password) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<UserAccount> googleLogin(String idToken) async {
    final response = await _client.post(
      _uri('/api/auth/google-login'),
      headers: _headers,
      body: jsonEncode({'idToken': idToken}),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<UserAccount> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<List<Vegetable>> getVegetables({bool includeInactive = false}) async {
    final response = await _client.get(
      _uri('/api/vegetables', {'includeInactive': '$includeInactive'}),
    );
    return _decodeList(response).map(Vegetable.fromJson).toList();
  }

  Future<Vegetable> getVegetableById(String id) async {
    final response = await _client.get(_uri('/api/vegetables/$id'));
    return Vegetable.fromJson(_decodeObject(response));
  }

  Future<Vegetable> createVegetable(Vegetable vegetable) async {
    final response = await _client.post(
      _uri('/api/vegetables'),
      headers: _headers,
      body: jsonEncode(vegetable.toApiJson()),
    );
    return Vegetable.fromJson(_decodeObject(response));
  }

  Future<Vegetable> updateVegetable(Vegetable vegetable) async {
    final response = await _client.put(
      _uri('/api/vegetables/${vegetable.id}'),
      headers: _headers,
      body: jsonEncode(vegetable.toApiJson()),
    );
    return Vegetable.fromJson(_decodeObject(response));
  }

  Future<void> deleteVegetable(String id) async {
    _ensureSuccess(await _client.delete(_uri('/api/vegetables/$id')));
  }

  Future<List<UserAccount>> getAccounts() async {
    final response = await _client.get(_uri('/api/accounts'));
    return _decodeList(response).map(UserAccount.fromJson).toList();
  }

  Future<UserAccount> createAccount(
    UserAccount account, {
    String password = '123456',
  }) async {
    final response = await _client.post(
      _uri('/api/accounts'),
      headers: _headers,
      body: jsonEncode({
        'fullName': account.name,
        'email': account.email,
        'password': password,
        'roleId': account.roleId,
        'isActive': account.active,
      }),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<UserAccount> updateAccount(UserAccount account) async {
    final response = await _client.put(
      _uri('/api/accounts/${account.id}'),
      headers: _headers,
      body: jsonEncode({
        'fullName': account.name,
        'email': account.email,
        'phoneNumber': null,
        'avatarUrl': null,
        'roleId': account.roleId,
        'isActive': account.active,
      }),
    );
    return UserAccount.fromJson(_decodeObject(response));
  }

  Future<void> deleteAccount(String id) async {
    _ensureSuccess(await _client.delete(_uri('/api/accounts/$id')));
  }

  Future<List<CartItem>> getCart(int accountId) async {
    final response = await _client.get(_uri('/api/accounts/$accountId/cart'));
    return _cartItems(_decodeObject(response));
  }

  Future<List<CartItem>> addCartItem(
    int accountId,
    Vegetable vegetable,
    int quantity,
  ) async {
    final response = await _client.post(
      _uri('/api/accounts/$accountId/cart/items'),
      headers: _headers,
      body: jsonEncode({
        'vegetableId': int.parse(vegetable.id),
        'quantity': quantity,
      }),
    );
    return _cartItems(_decodeObject(response));
  }

  Future<List<CartItem>> updateCartItem(
    int accountId,
    String vegetableId,
    int quantity,
  ) async {
    final response = await _client.put(
      _uri('/api/accounts/$accountId/cart/items/$vegetableId'),
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );
    return _cartItems(_decodeObject(response));
  }

  Future<List<CartItem>> removeCartItem(
    int accountId,
    String vegetableId,
  ) async {
    final response = await _client.delete(
      _uri('/api/accounts/$accountId/cart/items/$vegetableId'),
    );
    return _cartItems(_decodeObject(response));
  }

  Future<int> ensureDefaultAddress(UserAccount account) async {
    final response = await _client.get(
      _uri('/api/accounts/${account.id}/addresses'),
    );
    final addresses = _decodeList(response);
    if (addresses.isNotEmpty) return (addresses.first['id'] as num).toInt();

    final created = await _client.post(
      _uri('/api/accounts/${account.id}/addresses'),
      headers: _headers,
      body: jsonEncode({
        'recipientName': account.name,
        'phoneNumber': '0900000000',
        'addressLine': '12 Nguyễn Huệ',
        'ward': 'Phường Sài Gòn',
        'district': 'Quận 1',
        'province': 'TP. Hồ Chí Minh',
        'isDefault': true,
      }),
    );
    return (_decodeObject(created)['id'] as num).toInt();
  }

  Future<void> checkout(UserAccount account) async {
    final addressId = await ensureDefaultAddress(account);
    final response = await _client.post(
      _uri('/api/orders/checkout/${account.id}'),
      headers: _headers,
      body: jsonEncode({
        'addressId': addressId,
        'paymentMethod': 'Cod',
        'customerNote': null,
      }),
    );
    _ensureSuccess(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  List<CartItem> _cartItems(Map<String, dynamic> cart) =>
      (cart['items'] as List<dynamic>).map((raw) {
        final json = raw as Map<String, dynamic>;
        return CartItem(
          vegetable: Vegetable(
            id: json['vegetableId'].toString(),
            name: json['name'] as String,
            category: '',
            price: (json['price'] as num).toDouble(),
            unit: json['unit'] as String,
            description: '',
            imageUrl: (json['imageUrl'] ?? '') as String,
            stock: (json['availableStock'] as num).toInt(),
          ),
          quantity: (json['quantity'] as num).toInt(),
        );
      }).toList();

  Map<String, dynamic> _decodeObject(http.Response response) {
    _ensureSuccess(response);
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    _ensureSuccess(response);
    return (jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = 'Không thể kết nối máy chủ (${response.statusCode}).';
    try {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      message = (body['message'] ?? body['detail'] ?? body['title'] ?? message)
          .toString();
    } catch (_) {}
    throw ApiException(message, response.statusCode);
  }
}

final apiClient = ApiClient();
