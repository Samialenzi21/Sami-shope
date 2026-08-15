import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';
import 'package:shop/features/catalog/data/product_repository.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  late final ProductRepository _repository;
  late Future<List<StoreProduct>> _products;

  @override
  void initState() {
    super.initState();
    _repository = ProductRepository();
    _products = _repository.listProducts(limit: 20);
  }

  void _reload() {
    setState(() {
      _products = _repository.listProducts(limit: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            'Products',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<StoreProduct>>(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Unable to load products from the store.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        TextButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? const <StoreProduct>[];
              if (products.isEmpty) {
                return const Center(child: Text('No products available.'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == products.length - 1 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
                      image: product.thumbnail,
                      brandName: product.subtitle ?? '',
                      title: product.title,
                      price: product.price,
                      currencyCode: product.currencyCode ?? 'SAR',
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
