import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:wdb106_sample/model/model.dart';

final cartEmptyProvider = Provider(
  (ref) => ref.watch(cartTotalQuantityProvider.select((s) => s <= 0)),
);

final cartTotalQuantityProvider = Provider((ref) {
  return ref.watch(cartController).values.fold<int>(
    0,
    (sum, quantity) {
      return sum + quantity;
    },
  );
});

final cartTotalPriceLabelProvider = Provider(
  (ref) => '合計金額 ${ref.watch(cartTotalPriceProvider)}円+税',
);

final cartTotalPriceProvider = Provider((ref) {
  final itemMap = ref.watch(itemMapProvider);
  final cartMap = ref.watch(cartController);
  return cartMap.keys.fold<int>(
    0,
    (sum, id) {
      final item = itemMap[id]!;
      final quantity = cartMap[id]!;
      return sum + item.price * quantity;
    },
  );
});

final cartQuantityProviders = Provider.family<int, String>(
  (ref, id) => ref.watch(cartController.select((s) => s[id] ?? 0)),
);

final cartItemIdsProvider = Provider(
  (ref) =>
      ref.watch(cartController).keys.toList()..sort((a, b) => a.compareTo(b)),
);

final cartController = StateNotifierProvider<CartController, CartMap>(
  (ref) => CartController(),
);

typedef CartMap = Map<String, int>;

class CartController extends StateNotifier<CartMap> {
  CartController() : super({});

  void add(String id) {
    state = {
      ...state,
      id: (state[id] ?? 0) + 1,
    };
  }

  void delete(String id) {
    state = {
      ...state,
      id: state[id]! - 1,
    }..removeWhere((key, quantity) => quantity <= 0);
  }
}
