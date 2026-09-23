import '../models/enums.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'app_state.dart';

Future<void> seedDemoData(AppState state) async {
  final now = DateTime.now();

  final products = [
    Product(
      id: newId(),
      name: 'iPhone 17 Pro',
      brand: 'Apple',
      model: '256GB Space Gray',
      category: ProductCategory.elettronica,
       purchaseDate: now.subtract(const Duration(days: 700)),
       deliveryDate: now.subtract(const Duration(days: 702)),
       price: 1239.00,
       seller: 'MediaWorld Milano',
       sellerType: SellerType.professional,
       serialNumber: 'C39XG123R4D5',
       commercialWarrantyMonths: 12,
      commercialWarrantyProvider: 'Apple Italia',
      createdAt: now,
      updatedAt: now,
    ),
    Product(
      id: newId(),
      name: 'Smart TV Oled 55"',
      brand: 'LG',
      model: 'OLED55CX6LA',
      category: ProductCategory.elettronica,
       purchaseDate: now.subtract(const Duration(days: 200)),
       deliveryDate: now.subtract(const Duration(days: 200)),
       price: 1450.00,
       seller: 'Unieuro Online',
       sellerType: SellerType.professional,
      serialNumber: 'LG9982341234',
      extensionWarrantyMonths: 36,
      extensionWarrantyProvider: 'Serena360 TV',
      createdAt: now,
      updatedAt: now,
    ),
    Product(
      id: newId(),
      name: 'Lavatrice Slim 8Kg',
      brand: 'Samsung',
      model: 'WW80TA046TT',
      category: ProductCategory.elettrodomestici,
       purchaseDate: now.subtract(const Duration(days: 50)),
       deliveryDate: now.subtract(const Duration(days: 50)),
       price: 450.00,
       seller: 'Euronics Roma',
       sellerType: SellerType.professional,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final p in products) {
    await state.addProduct(p);
  }
}