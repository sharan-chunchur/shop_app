import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;
  static const params = {
    'key': 'AIzaSyCLlsM5tSKmvm5QwL7oJzTSy_EcFa-lfy4',
  };

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId{
    return _userId;
}

  Future<void> _userAuth(String email, String password, String authType) async {

    final url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$authType', params);

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _userId = responseData['localId'];
      _token = responseData['idToken'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
      'userId' : _userId,
      'token' : _token,
      'expiryDate' : _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _userAuth(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _userAuth(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogIn() async{
   try{
     final prefs = await SharedPreferences.getInstance();
     if(!prefs.containsKey('userData')){
       return false;
     }
     final extractedUserData = jsonDecode((prefs.getString('userData')!)) as Map<String, dynamic>;
     final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
     if(expiryDate.isBefore(DateTime.now())){
       return false;
     }
     _userId = extractedUserData['userId'];
     _token = extractedUserData['token'];
     _expiryDate = expiryDate;
     notifyListeners();
     _autoLogout();
     return true;
   }
   catch(e){
     print('caught error');
     print(e);
     return false;
   }

  }

  Future<void> logout() async{
    _userId = null;
    _token = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout(){
    if(_authTimer != null){
        _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
