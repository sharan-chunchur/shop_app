import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit_product-screen';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool isImageUrl = false;
  Product _editedProduct = Product(
    id: '',
    title: '',
    description: ' ',
    price: 0,
    imageUrl: '',
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit && (ModalRoute.of(context)?.settings.arguments) != null) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      _editedProduct =
          Provider.of<Products>(context, listen: false).findByID(productId);
      _isInit = false;
      isImageUrl = true;
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {
        isImageUrl = false;
      });
      Uri uri = Uri.parse(_imageUrlController.text);
      if (uri.isScheme('http') || uri.isScheme('https')) {
        String extension = uri.pathSegments.last.split('.').last.toLowerCase();
        if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg']
            .contains(extension)) {
          setState(() {
            isImageUrl = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() async{
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '') {
      try{
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      }catch(error){
        await showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('An error Occurred!'),
          content: const Text('Something is Wrong!'),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(ctx).pop();
            }, child: const Text('Okay'),)
          ],
        ));
      }
    } else {
      print(_editedProduct.id);
      try{
        await Provider.of<Products>(context, listen: false).addProducts(_editedProduct);
      }catch(error){
        await showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('An error Occurred!'),
          content: const Text('Something is Wrong>'),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(ctx).pop();
            }, child: const Text('Okay'),)
          ],
        ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          TextButton(
              onPressed: _saveForm,
              child: const Text(
                'Save',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              )),
        ],
      ),
      body: _isLoading? const Center(child: CircularProgressIndicator(),) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _form,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _editedProduct.title,
                  decoration: const InputDecoration(
                      label: Text('Title'), border: OutlineInputBorder()),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Title for the product';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: value!,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  initialValue: _editedProduct.price.toString(),
                  decoration: const InputDecoration(
                      label: Text('Price'), border: OutlineInputBorder()),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty || double.tryParse(value) == null) {
                      return 'Please enter price';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter price > 0';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: value!.isEmpty ? 0 : double.parse(value),
                      imageUrl: _editedProduct.imageUrl,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  initialValue: _editedProduct.description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      label: Text('Description'), border: OutlineInputBorder()),
                  focusNode: _descriptionFocusNode,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter description';
                    }
                    if (value.length < 10) {
                      return 'Enter description of at least 10 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: value!,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      isFavourite: _editedProduct.isFavourite,
                    );
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 30),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: (_imageUrlController.text.isEmpty || !isImageUrl)
                            ? const Center(
                                child: Text(
                                  'No image attached',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.fill,
                                child:
                                    Image.network(_imageUrlController.text))),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            label: Text('Image URL'),
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.url,
                        controller: _imageUrlController,
                        textInputAction: TextInputAction.done,
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) => _saveForm(),
                        validator: (value) {
                          Uri uri = Uri.parse(value!);
                          if (uri.isScheme('http') || uri.isScheme('https')) {
                            String extension = uri.pathSegments.last
                                .split('.')
                                .last
                                .toLowerCase();
                            if ([
                              'png',
                              'jpg',
                              'jpeg',
                              'gif',
                              'bmp',
                              'webp',
                              'svg'
                            ].contains(extension)) {
                              setState(() {
                                isImageUrl = true;
                              });
                            }
                          }

                          if (isImageUrl) {
                            return null;
                          } else {
                            return 'not a valid image URL';
                          }
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: value!,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
