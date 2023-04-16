import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';

import '../providers/cart.dart';
import '../widgets/appDrawer.dart';
import '../widgets/badge.dart' as bb;
import '../widgets/products_gridview.dart';
import 'package:provider/provider.dart';

enum menuType {
  showFavOnly,
  ShowAll,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFav = false;
  var _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    print('loading check 1');
    Future.delayed(Duration(seconds: 1)).then((_) => {
      Provider.of<Products>(context, listen: false).festAndSetProducts().then((value) {
        print('loading check 2');
        setState(() {
          _isLoading = false;
        });
      }
      )
    });
    super.initState();

  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (selectedVal) {
              setState(() {
                if (selectedVal == menuType.showFavOnly) {
                  _showOnlyFav = true;
                } else {
                  _showOnlyFav = false;
                }
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: menuType.showFavOnly,
                child: Text("Only Favourites"),
              ),
              PopupMenuItem(
                value: menuType.ShowAll,
                child: Text("Show All"),
              )
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, cha) => bb.Badge(
              value: cart.itemCount.toString(),
              color: Theme.of(context).colorScheme.secondary,
              child: cha!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGridview(_showOnlyFav),
    );
  }
}
