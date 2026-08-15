import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/features/cart/presentation/cart_controller.dart';
import 'package:shop/features/checkout/data/checkout_repository.dart';
import 'package:shop/features/checkout/data/models/store_order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final CheckoutRepository _checkoutRepository = CheckoutRepository();

  bool _isSubmitting = false;
  StoreOrder? _order;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cart = CartController.instance.cart;
    if (cart == null || cart.items.isEmpty) {
      _showError('Your cart is empty.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await _checkoutRepository.placePickupOrder(
        cartId: cart.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      CartController.instance.clearCompletedCart();
      if (!mounted) return;
      setState(() => _order = order);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _required(value);
    if (required != null) return required;

    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final required = _required(value);
    if (required != null) return required;

    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order != null) {
      return _OrderSuccess(order: order);
    }

    final cart = CartController.instance.cart;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart == null || cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(defaultPadding),
                children: [
                  Text(
                    'Contact details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  const _CheckoutChoiceCard(
                    icon: Icons.storefront_outlined,
                    title: 'Store Pickup',
                    subtitle: 'Pick up your order from the store in Riyadh.',
                  ),
                  const SizedBox(height: defaultPadding),
                  const _CheckoutChoiceCard(
                    icon: Icons.payments_outlined,
                    title: 'Pay at Pickup',
                    subtitle: 'Payment is collected by the merchant at pickup.',
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('Total'),
                        const Spacer(),
                        Text(
                          '${cart.total.toStringAsFixed(2)} ${cart.currencyCode.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _placeOrder,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Place order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CheckoutChoiceCard extends StatelessWidget {
  const _CheckoutChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
        children: [
          Icon(icon),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline),
        ],
      ),
    );
  }
}

class _OrderSuccess extends StatelessWidget {
  const _OrderSuccess({required this.order});

  final StoreOrder order;

  @override
  Widget build(BuildContext context) {
    final display = order.displayId?.toString() ?? order.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Order placed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 72),
              const SizedBox(height: defaultPadding),
              Text(
                'Order #$display',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                'Your order was created successfully. Pay when you pick it up from the store.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              Text(
                '${order.total.toStringAsFixed(2)} ${order.currencyCode.toUpperCase()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: defaultPadding * 1.5),
              FilledButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Continue shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
