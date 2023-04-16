import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  Future<void> toggleFavouriteStatus(String? token, String? userId) async{
    final url = Uri.https('shop-app-3a013-default-rtdb.firebaseio.com', 'userFavourites/$userId/$id.json', {'auth': token});
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try{
      final response = await http.put(url, body: jsonEncode(isFavourite));
      if (response.statusCode != 200) {
        print(response.body);
        throw Exception('Failed to delete item.');
      }
    }catch(error){
      isFavourite = oldStatus;
      notifyListeners();
      print(error);
      rethrow;
    }
  }
}
