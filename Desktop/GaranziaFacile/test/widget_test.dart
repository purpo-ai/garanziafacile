import 'package:flutter_test/flutter_test.dart';
import 'package:garanzia_facile/models/enums.dart';
import 'package:garanzia_facile/models/product.dart';
import 'package:garanzia_facile/models/warranty.dart';
import 'package:garanzia_facile/services/barcode_service.dart';
import 'package:garanzia_facile/services/receipt_ocr_service.dart';
import 'package:garanzia_facile/services/warranty_service.dart';
import 'package:garanzia_facile/services/storage_service.dart';
import 'package:garanzia_facile/state/app_state.dart';
import 'package:garanzia_facile/state/seed_demo.dart';

class _MockStorage extends StorageService {
  final AppDatabase _db = AppDatabase();

  @override
  Future<AppDatabase> load() async => Future.value(_db);

  @override
  Future<void> save(AppDatabase db) async {}

  @override
  Future<void> deleteAllData() async {}

  @override
  Future<String> get documentsDirPath async => '';
}

Product _product({
  String id = 'p1',
  String name = 'Lavatrice',
  String brand = 'Bosch',
  String model = 'WGB24400IT',
  DateTime? purchase,
  int? commercialMonths,
  int? extensionWarrantyMonths,
}) {
  return Product(
    id: id,
    name: name,
    brand: brand,
    model: model,
    category: ProductCategory.elettrodomestici,
    barcode: '8007842825888',
    serialNumber: 'SN123',
    purchaseDate: purchase ?? DateTime(2026, 10, 12),
    price: 599.90,
    seller: 'MediaWorld',
    commercialWarrantyMonths: commercialMonths,
    extensionWarrantyMonths: extensionWarrantyMonths,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

Product _productForDate(DateTime purchaseDate) {
  return Product(
    id: 'p1',
    name: 'Test',
    brand: '',
    model: '',
    category: ProductCategory.altro,
    purchaseDate: purchaseDate,
    seller: '',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WarrantyService', () {
    test('garanzia legale termina 24 mesi dopo l\u2019acquisto', () {
      final service = WarrantyService();
      final end = service.legalEnd(_productForDate(DateTime(2026, 1, 31)));
      expect(end, DateTime(2028, 1, 31));
    });

    test('gestisce fine mese (31 gennaio + 1 mese)', () {
      final service = WarrantyService();
      final end = service.legalEnd(_productForDate(DateTime(2026, 1, 31)));
      expect(end.day, 31);
    });

    test('periodi include legale, commerciale ed estensione', () {
      final service = WarrantyService();
      final periods = service.periodsFor(
        _product(commercialMonths: 36, extensionWarrantyMonths: 48),
      );
      expect(periods.map((p) => p.type),
          [WarrantyType.legal, WarrantyType.commercial, WarrantyType.extension]);
    });

    test('stato expiring sotto i 90 giorni', () {
      final service = WarrantyService();
      final lastMonth = DateTime.now().add(const Duration(days: 40));
      final product = Product(
        id: 'p2',
        name: 'X',
        brand: '',
        model: '',
        category: ProductCategory.altro,
        purchaseDate: lastMonth.subtract(
            const Duration(days: 24 * 30)),
        seller: 's',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final status = service.worstStatus(product);
      expect(status, WarrantyStatus.expiringSoon);
    });
  });

  group('BarcodeService', () {
    test('lookup trova prodotto noto', () {
      final entry = BarcodeService.lookup('8007842825888');
      expect(entry, isNotNull);
      expect(entry!.name, 'Lavatrice Washing Machine');
    });

    test('lookup non trova codice sconosciuto', () {
      final entry = BarcodeService.lookup('0000000000000');
      expect(entry, isNull);
    });

    test('search trova per nome', () {
      final results = BarcodeService.search('iPhone');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.name, 'iPhone 16 Pro');
    });

    test('search trova per marca', () {
      final results = BarcodeService.search('Samsung');
      expect(results.isNotEmpty, isTrue);
    });

    test('search torna vuoto per query vuota', () {
      final results = BarcodeService.search('');
      expect(results.isEmpty, isTrue);
    });

    test('search trova per modello', () {
      final results = BarcodeService.search('Series 4');
      expect(results.isNotEmpty, isTrue);
    });

    test('looksLikeEan riconosce EAN validi', () {
      final service = BarcodeService();
      expect(service.looksLikeEan('8007842825888'), isTrue);
      expect(service.looksLikeEan('12345678'), isTrue);
      expect(service.looksLikeEan('12345678901234'), isTrue);
    });

    test('looksLikeEan rifiuta EAN invalidi', () {
      final service = BarcodeService();
      expect(service.looksLikeEan('12345'), isFalse);
      expect(service.looksLikeEan('123456789012345'), isFalse);
      expect(service.looksLikeEan('abcdefgh'), isFalse);
    });
  });

  group('ReceiptOcrService', () {
    test('riconosce pattern totale', () {
      expect(ReceiptOcrService.totalKw.hasMatch('Totale: € 450,00'), isTrue);
    });
  });

  group('SeedDemo', () {
    test('seedDemoData aggiunge 3 prodotti', () async {
      final state = AppState(storage: _MockStorage());
      await seedDemoData(state);
      expect(state.products.length, 3);
      expect(state.products.any((p) => p.name.contains('iPhone')), isTrue);
      expect(state.products.any((p) => p.name.contains('Smart TV')), isTrue);
      expect(state.products.any((p) => p.name.contains('Lavatrice')), isTrue);
    });

    test('seedDemoData imposta categoria corretta', () async {
      final state = AppState(storage: _MockStorage());
      await seedDemoData(state);
      expect(state.products[0].category, ProductCategory.elettrodomestici);
      expect(state.products[2].category, ProductCategory.elettronica);
    });
  });

  group('AppState', () {
    test('export/import roundtrip', () async {
      final state = AppState(storage: _MockStorage())..loaded = true;
      await state.addProduct(_product());
      final json = state.exportJson();
      final state2 = AppState(storage: _MockStorage())..loaded = true;
      await state2.importBackup(json);
      expect(state2.products.length, 1);
      expect(state2.products.first.name, 'Lavatrice');
    });

    test('deleteAccountAndAllData cancella tutto', () async {
      final state = AppState(storage: _MockStorage())..loaded = true;
      await state.addProduct(_product());
      await state.addNotification(NotificationItem(
        id: 'n1',
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      ));
      await state.deleteAccountAndAllData();
      expect(state.products.isEmpty, isTrue);
      expect(state.notifications.isEmpty, isTrue);
      expect(state.acceptedDisclaimer, isFalse);
      expect(state.accountDeleted, isTrue);
    });

    test('addProduct ordina per data di acquisto', () async {
      final state = AppState(storage: _MockStorage())..loaded = true;
      await state.addProduct(_product(purchase: DateTime(2026, 1, 1)));
      await state.addProduct(
        _product(id: 'p2', name: 'B', purchase: DateTime(2026, 6, 1)),
      );
      expect(state.products[0].name, 'B');
      expect(state.products[1].name, 'Lavatrice');
    });

    test('deleteProduct rimuove anche claims e notifiche', () async {
      final state = AppState(storage: _MockStorage())..loaded = true;
      await state.addProduct(_product());
      final claim = Claim(
        id: 'c1',
        productId: 'p1',
        issueType: IssueType.difettoso,
        request: ClaimRequest.riparazione,
        letterBody: 'testo',
        status: ClaimStatus.bozza,
        createdAt: DateTime.now(),
      );
      state.addClaim(claim);
      await state.deleteProduct('p1');
      expect(state.products.isEmpty, isTrue);
      expect(state.claims.isEmpty, isTrue);
    });
  });

  group('Serialization', () {
    test('roundtrip prodotto', () {
      final original = _product(extensionWarrantyMonths: 36);
      final restored = Product.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.purchaseDate, original.purchaseDate);
      expect(restored.commercialWarrantyMonths, null);
      expect(restored.extensionWarrantyMonths, 36);
      expect(restored.category, ProductCategory.elettrodomestici);
    });

    test('roundtrip claim', () {
      final claim = Claim(
        id: 'c1',
        productId: 'p1',
        issueType: IssueType.difettoso,
        request: ClaimRequest.sostituzione,
        letterBody: 'testo',
        status: ClaimStatus.inviato,
        createdAt: DateTime(2026, 5, 9),
        sentAt: DateTime(2026, 5, 9, 10),
      );
      final restored = Claim.fromJson(claim.toJson());
      expect(restored.request, ClaimRequest.sostituzione);
      expect(restored.status, ClaimStatus.inviato);
      expect(restored.sentAt, claim.sentAt);
    });

    test('roundtrip notification', () {
      final notif = NotificationItem(
        id: 'n1',
        title: 'Test',
        message: 'Messaggio',
        createdAt: DateTime(2026, 1, 1),
        read: false,
      );
      final restored = NotificationItem.fromJson(notif.toJson());
      expect(restored.title, 'Test');
      expect(restored.read, isFalse);
    });
  });
}
