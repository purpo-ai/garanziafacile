import 'package:intl/intl.dart';

import '../models/enums.dart';
import '../models/product.dart';
import '../models/warranty.dart';

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = (totalMonths % 12) + 1;
  final day = date.day.clamp(1, _daysInMonth(year, month));
  return DateTime(year, month, day);
}

class WarrantyPeriod {
  final WarrantyType type;
  final DateTime end;
  final int monthsTotal;
  final String? provider;
  final WarrantySource source;

  const WarrantyPeriod({
    required this.type,
    required this.end,
    required this.monthsTotal,
    this.provider,
    this.source = WarrantySource.unknown,
  });

  bool get isExpired => end.isBefore(DateTime.now());
  int get daysRemaining => end.difference(DateTime.now()).inDays;

  WarrantyStatus get status {
    if (isExpired) return WarrantyStatus.expired;
    if (daysRemaining <= 90) return WarrantyStatus.expiringSoon;
    return WarrantyStatus.active;
  }

  String get statusLabel {
    switch (status) {
      case WarrantyStatus.active:
        return 'Attiva';
      case WarrantyStatus.expiringSoon:
        return 'In scadenza';
      case WarrantyStatus.expired:
        return 'Scaduta';
    }
  }
}

class WarrantyService {
  static const int legalMonths = 24;

  DateTime legalEnd(Product product) =>
      _addMonths(product.deliveryDate ?? product.purchaseDate, legalMonths);

  DateTime? commercialEnd(DateTime purchaseDate, int? months) =>
      months == null ? null : _addMonths(purchaseDate, months);

  DateTime? extensionEnd(DateTime purchaseDate, int? months) =>
      months == null ? null : _addMonths(purchaseDate, months);

  List<WarrantyPeriod> periodsFor(Product product) {
    final refDate = product.deliveryDate ?? product.purchaseDate;
    final list = <WarrantyPeriod>[
      WarrantyPeriod(
        type: WarrantyType.legal,
        end: legalEnd(product),
        monthsTotal: legalMonths,
        source: WarrantySource.calculated,
      ),
    ];
    if (product.commercialWarrantyMonths != null &&
        product.commercialWarrantyMonths! > 0) {
      list.add(WarrantyPeriod(
        type: WarrantyType.commercial,
        end: _addMonths(refDate, product.commercialWarrantyMonths!),
        monthsTotal: product.commercialWarrantyMonths!,
        provider: product.commercialWarrantyProvider,
        source: WarrantySource.userEntered,
      ));
    }
    if (product.extensionWarrantyMonths != null &&
        product.extensionWarrantyMonths! > 0) {
      list.add(WarrantyPeriod(
        type: WarrantyType.extension,
        end: _addMonths(refDate, product.extensionWarrantyMonths!),
        monthsTotal: product.extensionWarrantyMonths!,
        provider: product.extensionWarrantyProvider,
        source: WarrantySource.userEntered,
      ));
    }
    return list;
  }

  WarrantyStatus worstStatus(Product product) {
    final periods = periodsFor(product);
    if (periods.any((p) => p.status == WarrantyStatus.active)) {
      return WarrantyStatus.active;
    }
    if (periods.any((p) => p.status == WarrantyStatus.expiringSoon)) {
      return WarrantyStatus.expiringSoon;
    }
    return WarrantyStatus.expired;
  }

  int monthsSincePurchase(DateTime purchaseDate) {
    final now = DateTime.now();
    return (now.year - purchaseDate.year) * 12 +
        (now.month - purchaseDate.month);
  }

  String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
}