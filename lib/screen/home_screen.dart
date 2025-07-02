import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_with_api/widgets/my_navigation_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = [];
  String? _userEmail;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterProducts);
  }

  _initializeData() async {
    await _getUserEmail();
    if (mounted) {
      await _loadProducts();
    }
  }

  _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userEmail = prefs.getString('user_email');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadProducts() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      if (mounted) {
        setState(() {
          _products = [];
          _filteredProducts = [];
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userProductsKey = 'products_${_userEmail!}';
      final productsJson = prefs.getStringList(userProductsKey) ?? [];

      if (mounted) {
        setState(() {
          _products =
              productsJson.map((json) {
                final parts = json.split('|');
                return {
                  'name': parts[0],
                  'price': parts[1],
                  'image':
                      parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
                };
              }).toList();
          _filteredProducts = List.from(_products);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _filteredProducts = [];
        });
      }
    }
  }

  /// filter product for search
  _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts =
          _products.where((product) {
            return product['name'].toLowerCase().contains(query);
          }).toList();
    });
  }

  /// delete product
  _deleteProduct(int index) async {
    if (_userEmail == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userProductsKey = 'products_${_userEmail!}';

    setState(() {
      _products.removeAt(index);
      _filteredProducts = List.from(_products);
    });

    await prefs.setStringList(
      userProductsKey,
      _products
          .map(
            (product) =>
                '${product['name']}|${product['price']}|${product['image'] ?? ''}',
          )
          .toList(),
    );

    if (mounted) {
      Fluttertoast.showToast(
        msg: "Product deleted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// logout current user
  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      /// App bar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MyNavigationButton(
            btnIcon: Icons.menu_rounded,
            btnBackground: Colors.grey.shade300,
            iconColor: Colors.black87,
            iconSize: 27,
            onPressed: () {},
          ),
        ),
        actions: [
          SizedBox(
            height: size.width * 0.11,
            width: size.width * 0.11,
            child: MyNavigationButton(
              btnIcon: !_isSearchOpen ? Icons.search : Icons.close,
              iconSize: 22,
              iconColor: Colors.black87,
              onPressed: () {
                setState(() {
                  _isSearchOpen = !_isSearchOpen;
                });
              },
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            height: size.width * 0.11,
            width: size.width * 0.11,
            child: MyNavigationButton(
              btnIcon: CupertinoIcons.square_arrow_right,
              iconSize: 22,
              iconColor: Colors.black87,
              onPressed: _logout,
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18),

                      Text(
                        "Hi-Fi Shop & Service",
                        style: TextStyle(
                          fontSize: 27,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        "Audio shop on Rustaveli Ave 57.",
                        style: TextStyle(color: Colors.black38),
                      ),
                      Text(
                        "This shop offers shop  product and services ",
                        style: TextStyle(color: Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),

              /// search box
              _isSearchOpen
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: "Search products",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  )
                  : SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Products",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " ${_products.length}",
                            style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text("Show all", style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),

              /// filtered product show here
              _filteredProducts.isEmpty
                  ? const Expanded(
                    child: Center(
                      child: Text(
                        "No Products Found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
                  : GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      /// product card
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Product Image
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child:
                                      product['image'] != null &&
                                              product['image'].isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: product['image'],
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                            errorWidget: (context, url, error) {
                                              print('Image load error: $error');
                                              print(
                                                'Image URL: ${product['image']}',
                                              );
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Image not found',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            httpHeaders: {'Accept': 'image/*'},
                                          )
                                          : Container(
                                            height: 120,
                                            width: double.infinity,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.shopping_bag,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),

                                /// delete button
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: SizedBox(
                                    height: size.width * 0.1,
                                    width: size.width * 0.1,
                                    child: MyNavigationButton(
                                      btnIcon: Icons.delete,
                                      btnBackground: Colors.white70,
                                      btnRadius: 12,
                                      iconSize: 21,
                                      iconColor: Colors.red,
                                      onPressed:
                                          () => _deleteProduct(
                                            _products.indexWhere(
                                              (p) =>
                                                  p['name'] ==
                                                      product['name'] &&
                                                  p['price'] ==
                                                      product['price'],
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            /// Product Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  /// price
                                  Text(
                                    "\$${product['price']}",
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Delete Button
                          ],
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),

      /// add product button
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          _loadProducts();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 27),
      ),
    );
  }
}
