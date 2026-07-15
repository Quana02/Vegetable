import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

class FirebaseEmailAuthException implements Exception {
  const FirebaseEmailAuthException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final http.Client _client;

  FirebaseAuthService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => DefaultFirebaseOptions.currentPlatform.apiKey;

  Future<String?> signInWithGoogleAndGetIdToken() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(
      credential,
    );
    return userCredential.user?.getIdToken();
  }

  Future<String> signInWithEmailAndGetIdToken(
    String email,
    String password,
  ) async {
    final json = await _postIdentityToolkit(
      'accounts:signInWithPassword',
      {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    return json['idToken'] as String;
  }

  Future<String> registerWithEmailAndGetIdToken({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final json = await _postIdentityToolkit(
      'accounts:signUp',
      {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );

    final idToken = json['idToken'] as String;
    await _postIdentityToolkit(
      'accounts:update',
      {
        'idToken': idToken,
        'displayName': fullName,
        'returnSecureToken': false,
      },
    );
    return idToken;
  }

  Future<Map<String, dynamic>> _postIdentityToolkit(
    String method,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/$method',
        {'key': _apiKey},
      ),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) return json;

    final error = (json['error'] as Map<String, dynamic>?) ?? {};
    final code = (error['message'] ?? 'FIREBASE_AUTH_ERROR').toString();
    throw FirebaseEmailAuthException(code, _messageForCode(code));
  }

  String _messageForCode(String code) => switch (code) {
    'EMAIL_EXISTS' => 'Email này đã tồn tại trên Firebase.',
    'EMAIL_NOT_FOUND' => 'Email chưa tồn tại trên Firebase.',
    'INVALID_PASSWORD' => 'Mật khẩu Firebase không đúng.',
    'INVALID_LOGIN_CREDENTIALS' => 'Email hoặc mật khẩu Firebase không đúng.',
    'WEAK_PASSWORD : Password should be at least 6 characters' =>
      'Mật khẩu tối thiểu 6 ký tự.',
    _ => 'Firebase Auth lỗi: $code',
  };
}

final firebaseAuthService = FirebaseAuthService();
