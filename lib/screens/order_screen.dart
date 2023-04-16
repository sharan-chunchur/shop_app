import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/appDrawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/OrderScreen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture(){
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        body:FutureBuilder(
          future: _ordersFuture,
          builder: (context, snapshotData) {
            if(snapshotData.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if(snapshotData.hasError){
              return const Center(child: Text('An error has occurred'));
            }else{
              return Consumer<Orders>(builder: (ctx, orderData, child){
               return ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) => OrderItem(
                    order: orderData.orders[index],
                  ),
                );
              });
            }
          },
        ),
    );
  }
}
