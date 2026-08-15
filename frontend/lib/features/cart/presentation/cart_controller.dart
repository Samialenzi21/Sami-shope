import 'package:flutter/foundation.dart';
import 'package:shop/features/cart/data/cart_repository.dart';
import 'package:shop/features/cart/data/models/store_cart.dart';
import 'package:shop/features/catalog/data/models/store_product.dart';

class CartController extends ChangeNotifier {
  CartController._({CartRepository? repository})
      : _repository = repository ?? CartRepository();

  static final CartController instance = CartController._();

  final CartRepository _repository;

  StoreCart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  StoreCart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get quantity => _cart?.quantity ?? 0;

  Future<void> load() async {
    await _run(() async {
      _cart = await _repository.retrieveCurrentCart();
    });
  }

  Future<void> addProduct(StoreProduct product) async {
    await _run(() async {
      _cart = await _repository.addProduct(product);
    });
  }

  Future<void> increment(StoreCartItem item) async {
    await _run(() async {
      _cart = await _repository.updateQuantity(item, item.quantity + 1);
    });
  }

  Future<void> decrement(StoreCartItem item) async {
    await _run(() async {
      _cart = item.quantity <= 1
          ? await _repository.removeItem(item)
          : await _repository.updateQuantity(item, item.quantity - 1);
    });
  }

  Future<void> remove(StoreCartItem item) async {
    await _run(() async {
      _cart = await _repository.removeItem(item);
    });
  }

  void clearCompletedCart() {
    _repository.clearSession();
    _cart = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
