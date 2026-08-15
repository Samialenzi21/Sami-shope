import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/features/cart/data/models/store_cart.dart';
import 'package:shop/features/cart/presentation/cart_controller.dart';
import 'package:shop/route/route_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _controller = CartController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) return;
      _showError();
    }
  }

  Future<void> _perform(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      if (!mounted) return;
      _showError();
    }
  }

  void _showError() {
    final message = _controller.errorMessage ?? 'Unable to update the cart.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final cart = _controller.cart;
        final items = cart?.items ?? const <StoreCartItem>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _controller.quantity == 0
                  ? 'Cart'
                  : 'Cart (${_controller.quantity})',
            ),
          ),
          body: Stack(
            children: [
              if (items.isEmpty)
                const _EmptyCart()
              else
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    defaultPadding,
                    defaultPadding,
                    160,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: defaultPadding),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemCard(
                      item: item,
                      currencyCode: cart?.currencyCode ?? 'sar',
                      enabled: !_controller.isLoading,
                      onIncrement: () =>
                          _perform(() => _controller.increment(item)),
                      onDecrement: () =>
                          _perform(() => _controller.decrement(item)),
                      onRemove: () => _perform(() => _controller.remove(item)),
                    );
                  },
                ),
              if (cart != null && items.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _CartSummary(cart: cart),
                ),
              if (_controller.isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              'Add an item from the menu to start an order.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.currencyCode,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final StoreCartItem item;
  final String currencyCode;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CartThumbnail(url: item.thumbnail),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: defaultPadding / 2),
                Text(
                  '${item.lineTotal.toStringAsFixed(2)} ${currencyCode.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: enabled ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: enabled ? onIncrement : null,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: enabled ? onRemove : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartThumbnail extends StatelessWidget {
  const _CartThumbnail({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final validUrl = url != null && url!.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(defaultBorderRadious),
      ),
      child: Container(
        width: 84,
        height: 84,
        color: Theme.of(context).dividerColor,
        child: validUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
              )
            : const Icon(Icons.image_outlined),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final StoreCart cart;

  @override
  Widget build(BuildContext context) {
    final currency = cart.currencyCode.toUpperCase();

    return Material(
      elevation: 12,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${cart.total.toStringAsFixed(2)} $currency',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, checkoutScreenRoute);
                  },
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
