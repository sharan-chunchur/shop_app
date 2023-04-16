import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/user_product_screen.dart';
import '../screens/order_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var _isLoading =false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Heloo there!"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: () {
              Navigator.pushReplacementNamed(context, OrderScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.manage_accounts),
            title: Text("Manage products"),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, UserProductScreen.routeName);
            },
          ),
          _isLoading ? const CircularProgressIndicator() : ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Log Outa"),
            onTap: () async{
              final nav =Navigator.of(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final navi = Navigator.of(context);
                  return AlertDialog(
                    title: const Text('LogOut'),
                    content: const Text('Are you sure you want to Logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>navi.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async{
                          setState(() {
                            _isLoading =true;
                          });
                          await Provider.of<Auth>(context, listen: false).logout();
                          navi.pop();
                          nav.pop();
                          nav.pushReplacementNamed('/');
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
