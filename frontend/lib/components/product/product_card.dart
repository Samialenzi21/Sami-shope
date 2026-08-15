import 'package:flutter/material.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.currencyCode = 'USD',
    this.priceAfetDiscount,
    this.dicountpercent,
    required this.press,
  });

  final String? image;
  final String brandName, title;
  final double? price;
  final String currencyCode;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final VoidCallback press;

  String _formatPrice(double value) {
    return '${value.toStringAsFixed(2)} ${currencyCode.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(140, 220),
        maximumSize: const Size(140, 220),
        padding: const EdgeInsets.all(8),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                if (image != null && image!.isNotEmpty)
                  NetworkImageWithLoader(
                    image!,
                    radius: defaultBorderRadious,
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined),
                  ),
                if (dicountpercent != null)
                  Positioned(
                    right: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2,
                      ),
                      height: 16,
                      decoration: const BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(defaultBorderRadious),
                        ),
                      ),
                      child: Text(
                        '$dicountpercent% off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: defaultPadding / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brandName.isNotEmpty) ...[
                    Text(
                      brandName.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  if (price == null)
                    const Text(
                      'Price unavailable',
                      style: TextStyle(fontSize: 11),
                    )
                  else if (priceAfetDiscount != null)
                    Row(
                      children: [
                        Text(
                          _formatPrice(priceAfetDiscount!),
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: defaultPadding / 4),
                        Expanded(
                          child: Text(
                            _formatPrice(price!),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _formatPrice(price!),
                      style: const TextStyle(
                        color: Color(0xFF31B0D8),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
