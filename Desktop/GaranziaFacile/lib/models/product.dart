import 'enums.dart';

class Attachment {
  final String id;
  final AttachmentType type;
  final String title;
  final String? filePath;
  final String? note;

  const Attachment({
    required this.id,
    required this.type,
    required this.title,
    this.filePath,
    this.note,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json['id'] as String,
        type: AttachmentType.values.byName(json['type'] as String),
        title: json['title'] as String,
        filePath: json['filePath'] as String?,
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'filePath': filePath,
        'note': note,
      };
}

class TimelineEvent {
  final String id;
  final TimelineEventType type;
  final DateTime date;
  final String description;

  const TimelineEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.description,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        id: json['id'] as String,
        type: TimelineEventType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'date': date.toIso8601String(),
        'description': description,
      };
}

class Product {
  final String id;
  String name;
  String brand;
  String model;
  ProductCategory category;
  String? barcode;
  String? serialNumber;
  DateTime purchaseDate;
  DateTime? deliveryDate;
  double? price;
  String seller;
  SellerType sellerType;
  AcquisitionType acquisitionType;
  String? sellerAddress;
  String? notes;
  int? commercialWarrantyMonths;
  String? commercialWarrantyProvider;
  int? extensionWarrantyMonths;
  String? extensionWarrantyProvider;
  List<Attachment> attachments;
  List<TimelineEvent> timeline;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    this.barcode,
    this.serialNumber,
    required this.purchaseDate,
    this.deliveryDate,
    this.price,
    required this.seller,
    this.sellerAddress,
    this.sellerType = SellerType.professional,
    this.acquisitionType = AcquisitionType.personal,
    this.notes,
    this.commercialWarrantyMonths,
    this.commercialWarrantyProvider,
    this.extensionWarrantyMonths,
    this.extensionWarrantyProvider,
    List<Attachment>? attachments,
    List<TimelineEvent>? timeline,
    required this.createdAt,
    required this.updatedAt,
  })  : attachments = attachments ?? [],
        timeline = timeline ?? [];

  String get displayName => [brand, model, name]
      .where((s) => s.isNotEmpty)
      .join(' ')
      .trim();

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String? ?? '',
        model: json['model'] as String? ?? '',
        category: ProductCategory.values.byName(json['category'] as String),
        barcode: json['barcode'] as String?,
        serialNumber: json['serialNumber'] as String?,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        deliveryDate: json['deliveryDate'] != null
            ? DateTime.parse(json['deliveryDate'] as String)
            : null,
        price: (json['price'] as num?)?.toDouble(),
        seller: json['seller'] as String? ?? '',
        sellerAddress: json['sellerAddress'] as String?,
        sellerType: SellerType.values.byName(
            json['sellerType'] as String? ?? 'professional'),
        acquisitionType: AcquisitionType.values.byName(
            json['acquisitionType'] as String? ?? 'personal'),
        notes: json['notes'] as String?,
        commercialWarrantyMonths: json['commercialWarrantyMonths'] as int?,
        commercialWarrantyProvider: json['commercialWarrantyProvider'] as String?,
        extensionWarrantyMonths: json['extensionWarrantyMonths'] as int?,
        extensionWarrantyProvider: json['extensionWarrantyProvider'] as String?,
        attachments: (json['attachments'] as List<dynamic>? ?? [])
            .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
            .toList(),
        timeline: (json['timeline'] as List<dynamic>? ?? [])
            .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'model': model,
        'category': category.name,
        'barcode': barcode,
        'serialNumber': serialNumber,
        'purchaseDate': purchaseDate.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'price': price,
        'seller': seller,
        'sellerAddress': sellerAddress,
        'sellerType': sellerType.name,
        'acquisitionType': acquisitionType.name,
        'notes': notes,
        'commercialWarrantyMonths': commercialWarrantyMonths,
        'commercialWarrantyProvider': commercialWarrantyProvider,
        'extensionWarrantyMonths': extensionWarrantyMonths,
        'extensionWarrantyProvider': extensionWarrantyProvider,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'timeline': timeline.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Product copyWith({
    String? name,
    String? brand,
    String? model,
    ProductCategory? category,
    String? barcode,
    String? serialNumber,
    DateTime? purchaseDate,
    DateTime? deliveryDate,
    double? price,
    String? seller,
    String? sellerAddress,
    SellerType? sellerType,
    AcquisitionType? acquisitionType,
    String? notes,
    int? commercialWarrantyMonths,
    String? commercialWarrantyProvider,
    int? extensionWarrantyMonths,
    String? extensionWarrantyProvider,
    List<Attachment>? attachments,
    List<TimelineEvent>? timeline,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      price: price ?? this.price,
      seller: seller ?? this.seller,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      sellerType: sellerType ?? this.sellerType,
      acquisitionType: acquisitionType ?? this.acquisitionType,
      notes: notes ?? this.notes,
      commercialWarrantyMonths:
          commercialWarrantyMonths ?? this.commercialWarrantyMonths,
      commercialWarrantyProvider:
          commercialWarrantyProvider ?? this.commercialWarrantyProvider,
      extensionWarrantyMonths:
          extensionWarrantyMonths ?? this.extensionWarrantyMonths,
      extensionWarrantyProvider:
          extensionWarrantyProvider ?? this.extensionWarrantyProvider,
      attachments: attachments ?? this.attachments,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ClaimCommunication {
  final String id;
  final CommunicationMethod method;
  final String subject;
  final DateTime sentAt;

  const ClaimCommunication({
    required this.id,
    required this.method,
    required this.subject,
    required this.sentAt,
  });

  factory ClaimCommunication.fromJson(Map<String, dynamic> json) =>
      ClaimCommunication(
        id: json['id'] as String,
        method:
            CommunicationMethod.values.byName(json['method'] as String),
        subject: json['subject'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method.name,
        'subject': subject,
        'sentAt': sentAt.toIso8601String(),
      };
}

class Claim {
  final String id;
  final String productId;
  final IssueType issueType;
  final ClaimRequest request;
  final String? whatHappened;
  final DateTime? defectOccurredAt;
  final String letterBody;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final List<ClaimCommunication> communications;

  const Claim({
    required this.id,
    required this.productId,
    required this.issueType,
    required this.request,
    this.whatHappened,
    this.defectOccurredAt,
    required this.letterBody,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.communications = const [],
  });

  Claim copyWith({
    ClaimStatus? status,
    DateTime? sentAt,
    List<ClaimCommunication>? communications,
  }) {
    return Claim(
      id: id,
      productId: productId,
      issueType: issueType,
      request: request,
      whatHappened: whatHappened,
      defectOccurredAt: defectOccurredAt,
      letterBody: letterBody,
      status: status ?? this.status,
      createdAt: createdAt,
      sentAt: sentAt ?? this.sentAt,
      communications: communications ?? this.communications,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        id: json['id'] as String,
        productId: json['productId'] as String,
        issueType: IssueType.values.byName(json['issueType'] as String),
        request: ClaimRequest.values.byName(json['request'] as String),
        whatHappened: json['whatHappened'] as String?,
        defectOccurredAt: json['defectOccurredAt'] != null
            ? DateTime.parse(json['defectOccurredAt'] as String)
            : null,
        letterBody: json['letterBody'] as String,
        status: ClaimStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        sentAt: json['sentAt'] != null
            ? DateTime.parse(json['sentAt'] as String)
            : null,
        communications: (json['communications'] as List<dynamic>? ?? [])
            .map((e) =>
                ClaimCommunication.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'issueType': issueType.name,
        'request': request.name,
        'whatHappened': whatHappened,
        'defectOccurredAt': defectOccurredAt?.toIso8601String(),
        'letterBody': letterBody,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'communications': communications.map((c) => c.toJson()).toList(),
      };
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? productId;
  final DateTime createdAt;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.productId,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        productId: json['productId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'productId': productId,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}