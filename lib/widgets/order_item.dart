import 'dart:math';

import 'package:flutter/material.dart';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem({required this.order});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              child: FittedBox(child: Text(widget.order.amount.toString())),
            ),
            title: Text(
                DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime),
                style: Theme.of(context).textTheme.titleLarge),
            // subtitle:
            //     Text('$dateTime', style: Theme.of(context).textTheme.titleSmall),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? min(widget.order.products.length * 30.0 + 100.0, 200) : 0,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(widget.order.products[index].title),
                        subtitle: Text(
                            '\$${widget.order.products[index].price}x ${widget.order.products[index].quantity}'),
                        trailing: Chip(
                          label: Text(
                            '\$${widget.order.products[index].quantity * widget.order.products[index].price}',
                          ),
                        ),
                      );
                    },
                    itemCount: widget.order.products.length,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
