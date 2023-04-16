import 'dart:convert';

import 'package:flutter/material.dart';

import '../providers/cart.dart';

import 'package:http/http.dart' as http;

class OrderItem {
  String id;
  double amount;
  List<CartItem> products;
  DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders extends ChangeNotifier {
  String? authToken;
  String? userId;
  List<OrderItem> _orders;
  Map<String, String>? params;
  Orders(this.authToken, this.userId, this._orders){
    if (authToken != null) {
      params = {
        'auth': authToken!,
      };
    }
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    Map<String, String> filterParams = {
      'auth': authToken!,
      'orderBy': json.encode("creatorId"),
      'equalTo': json.encode(userId),
    };
    final url =
        Uri.https('shop-app-3a013-default-rtdb.firebaseio.com', '/orders.json', filterParams);
    final response = await http.get(url);
    final List<OrderItem> loadedItems = [];
    print(jsonDecode(response.body));
    if(jsonDecode(response.body) == null){
      return;
    }
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderItemData) {
      loadedItems.add(OrderItem(
          id: orderId,
          amount: orderItemData['amount'],
          products: (orderItemData['products'] as List<dynamic>)
              .map((prodItem) => CartItem(
                  id: prodItem['id'],
                  title: prodItem['title'],
                  quantity: prodItem['quantity'],
                  price: prodItem['price']))
              .toList(),
          dateTime: DateTime.parse(orderItemData['dateTime'])));
    });
    _orders =loadedItems;
    notifyListeners();
  }

  Future<void> addOrders(List<CartItem> cartProducts, double total) async {
    if (cartProducts.isNotEmpty) {
      final _dateTime = DateTime.now();
      final url = Uri.https(
          'shop-app-3a013-default-rtdb.firebaseio.com', '/orders.json', params);
      final response = await http.post(url,
          body: jsonEncode({
            'id': DateTime.now().toString(),
            'amount': total,
            'products': cartProducts
                .map((cartItem) => {
                      'id': cartItem.id,
                      'title': cartItem.title,
                      'quantity': cartItem.quantity,
                      'price': cartItem.price
                    })
                .toList(),
            'dateTime': _dateTime.toIso8601String(),
            'creatorId': userId,
          }));
      print(authToken);
      print(jsonDecode(response.body));
      _orders.insert(
        0,
        OrderItem(
            id: jsonDecode(response.body) ['name'],
            amount: total,
            products: cartProducts,
            dateTime: _dateTime),
      );
    }
    notifyListeners();
  }
}
