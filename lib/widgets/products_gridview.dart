import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'product_item.dart';
import 'package:provider/provider.dart';

class ProductsGridview extends StatefulWidget {
  final bool showFavs;
  ProductsGridview(this.showFavs);

  @override
  State<ProductsGridview> createState() => _ProductsGridviewState();
}

class _ProductsGridviewState extends State<ProductsGridview> {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    var products = widget.showFavs ? productsData.favItems : productsData.items;
    void onChange() {
      setState(() {
        products = productsData.favItems;
      });
    }

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 4 / 3),
      itemBuilder: (context, index) => ChangeNotifierProvider<Product>.value(
        value: products[index],
        child: ProductItem(onChange),
      ),
    );
  }
}
