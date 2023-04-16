import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../providers/products.dart';
import '../widgets/appDrawer.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatefulWidget {
  static const routeName = 'User-Products';
  const UserProductScreen({Key? key}) : super(key: key);

  @override
  State<UserProductScreen> createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false).festAndSetProducts(true).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final products = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body:_isLoading ? const Center(child: CircularProgressIndicator(),) : RefreshIndicator(
        onRefresh: () async{
          Provider.of<Products>(context, listen: false).festAndSetProducts(true);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.builder(
            itemBuilder: (ctx, index) {
              return UserProductItem(
                  id: products.items[index].id,
                  title: products.items[index].title,
                  imageUrl: products.items[index].imageUrl);
            },
            itemCount: products.items.length,
          ),
        ),
      ),
    );
  }
}
