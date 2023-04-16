import 'dart:convert';

import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items;
  String? authToken;
  String? userId;
  Map<String, String>? params;

  Products(this.authToken, this.userId, this._items) {
    if (authToken != null) {
      params = {
        'auth': authToken!,
      };
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findByID(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> festAndSetProducts([bool filterByUserId=false]) async {
    Map<String, String>? filterParams = filterByUserId ? {
      'auth': authToken!,
      'orderBy': json.encode("creatorId"),
      'equalTo': json.encode(userId),
    } : params;
    var url = Uri.https(
      'shop-app-3a013-default-rtdb.firebaseio.com',
      '/products.json',
      filterParams,
    );
    try {
      final response = await http.get(url);
      if (jsonDecode(response.body) == null) {
        return;
      }
      final retrievedData = jsonDecode(response.body) as Map<String, dynamic>;
      url = Uri.https(
        'shop-app-3a013-default-rtdb.firebaseio.com',
        'userFavourites/$userId.json',
        params,
      );
      final favResponse = await http.get(url);
      final favData = jsonDecode(favResponse.body);
      final List<Product> loadedProducts = [];
      retrievedData.forEach((prodId, prodData) {
        final product = Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavourite: favData == null ? false : favData[prodId] ?? false,
        );
        loadedProducts.add(product);
        print(product);
      });
      _items = loadedProducts;
      print(_items);
    } catch (error) {
      print('check 1 $error');
    }
    notifyListeners();
  }

  Future<void> addProducts(Product product) async {
    final url = Uri.https(
        'shop-app-3a013-default-rtdb.firebaseio.com', '/products.json', params);
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));
      print(jsonDecode(response.body));
      final newProduct = Product(
        id: jsonDecode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newDataProdut) async {
    final url = Uri.https(
        'shop-app-3a013-default-rtdb.firebaseio.com', '/products/$id.json', params);
    try {
      final response = await http.patch(url,
          body: jsonEncode({
            'title': newDataProdut.title,
            'description': newDataProdut.description,
            'imageUrl': newDataProdut.imageUrl,
            'price': newDataProdut.price,
          }));
      final prodIndex =
          _items.indexWhere((prod) => prod.id == newDataProdut.id);
      _items[prodIndex] = newDataProdut;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
        'shop-app-3a013-default-rtdb.firebaseio.com', '/products/$id.json', params);
    final index = _items.indexWhere((element) => element.id == id);
    Product? existingProd = _items[index];
    _items.removeAt(index);
    notifyListeners();

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        existingProd = null;
      } else {
        print(response.statusCode);
        throw Exception('Failed to delete item.');
      }
    } catch (error) {
      print(error);
      _items.insert(index, existingProd!);
      notifyListeners();
      rethrow;
    }
  }
}
