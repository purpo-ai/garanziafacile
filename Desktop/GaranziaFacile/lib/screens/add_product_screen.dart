import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';
import '../services/storage_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gf/gf_badge.dart';
import '../widgets/gf/gf_buttons.dart';
import '../widgets/gf/gf_foundation.dart';
import '../widgets/gf/gf_icons.dart';
import '../widgets/gf/gf_motion.dart';
import 'barcode_scan_screen.dart';
import 'label_scan_screen.dart';
import 'receipt_scan_screen.dart';

enum AddProductMode { pick, scan, manual }

class AddProductScreen extends StatefulWidget {
  final ScanResult? scanResult;
  final CatalogEntry? catalogEntry;
  final Product? product;
  final AddProductMode initialMode;
  const AddProductScreen({
    super.key,
    this.scanResult,
    this.catalogEntry,
    this.product,
    this.initialMode = AddProductMode.pick,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

enum _Stage { choose, confirm, form }

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _barcode;
  late final TextEditingController _serial;
  late final TextEditingController _price;
  late final TextEditingController _seller;
  late final TextEditingController _sellerAddress;
  late final TextEditingController _commercialMonths;
  late final TextEditingController _commercialProvider;
  late final TextEditingController _extensionMonths;
  late final TextEditingController _extensionProvider;
  late final TextEditingController _notes;

  ProductCategory _category = ProductCategory.altro;
  late DateTime _purchaseDate;
  late _Stage _stage;
  _Stage get _effectiveStage {
    if (widget.product != null) return _Stage.form;
    return _stage;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _stage = _Stage.choose;

    _name = TextEditingController(text: p?.name ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _model = TextEditingController(text: p?.model ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _serial = TextEditingController(text: p?.serialNumber ?? '');
    _price =
        TextEditingController(text: p?.price?.toStringAsFixed(2) ?? '');
    _seller = TextEditingController(text: p?.seller ?? '');
    _sellerAddress = TextEditingController(text: p?.sellerAddress ?? '');
    _commercialMonths = TextEditingController(
        text: p?.commercialWarrantyMonths?.toString() ?? '');
    _commercialProvider =
        TextEditingController(text: p?.commercialWarrantyProvider ?? '');
    _extensionMonths = TextEditingController(
        text: p?.extensionWarrantyMonths?.toString() ?? '');
    _extensionProvider =
        TextEditingController(text: p?.extensionWarrantyProvider ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');

    _category = p?.category ?? ProductCategory.altro;
    _purchaseDate = p?.purchaseDate ?? DateTime.now();

    final cat = widget.catalogEntry;
    if (cat != null) {
      _name.text = cat.name;
      _brand.text = cat.brand;
      _model.text = cat.model;
      _category = cat.category;
      if (cat.barcode.isNotEmpty) _barcode.text = cat.barcode;
    }

    if (widget.scanResult != null) {
      _applyScan(widget.scanResult!);
      _stage = widget.scanResult!.entry != null
          ? _Stage.confirm
          : _Stage.form;
    } else if (widget.catalogEntry != null) {
      _stage = _Stage.form;
    } else if (widget.product == null) {
      switch (widget.initialMode) {
        case AddProductMode.pick:
          _stage = _Stage.choose;
        case AddProductMode.scan:
          _stage = _Stage.choose;
          WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
        case AddProductMode.manual:
          _stage = _Stage.form;
      }
    }
  }

  void _applyScan(ScanResult r) {
    setState(() {
      _name.text = r.entry?.name ?? _name.text;
      _brand.text = r.entry?.brand ?? _brand.text;
      _model.text = r.entry?.model ?? _model.text;
      if (r.barcode.isNotEmpty) _barcode.text = r.barcode;
      if (r.entry != null) {
        _category = r.entry!.category;
        _autoFillWarrantyDefaults();
      }
    });
  }

  void _autoFillWarrantyDefaults() {
    final brand = _brand.text.trim();
    if (_commercialProvider.text.trim().isEmpty && brand.isNotEmpty) {
      _commercialProvider.text = brand;
    }
    if (_commercialMonths.text.trim().isEmpty) {
      _commercialMonths.text = _defaultCommercialMonths(_category).toString();
    }
  }

  int _defaultCommercialMonths(ProductCategory category) {
    switch (category) {
      case ProductCategory.elettronica:
      case ProductCategory.telefonia:
      case ProductCategory.informatica:
      case ProductCategory.audioVideo:
      case ProductCategory.abbigliamento:
      case ProductCategory.giocattoli:
      case ProductCategory.altro:
        return 12;
      case ProductCategory.elettrodomestici:
      case ProductCategory.mobili:
        return 24;
    }
  }

  void _lookupCatalog() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      gfSnack(context, 'Inserisci prima il nome del prodotto.');
      return;
    }
    final results = BarcodeService.search(name);
    if (results.isEmpty) {
      gfSnack(context, 'Nessuna corrispondenza nel catalogo.');
      return;
    }
    final best = results.first;
    setState(() {
      _name.text = best.name;
      _brand.text = best.brand;
      _model.text = best.model;
      _category = best.category;
      _autoFillWarrantyDefaults();
    });
    gfHaptic(type: GFHaptic.medium);
  }

  String? _receiptPath;

  Future<void> _scanReceipt() async {
    final result = await Navigator.of(context).push<ReceiptScreenResult>(
      MaterialPageRoute(builder: (_) => const ReceiptScanScreen()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _receiptPath = result.imagePath;
      if (result.storeName != null && _seller.text.trim().isEmpty) {
        _seller.text = result.storeName!;
      }
      if (result.purchaseDate != null) {
        _purchaseDate = result.purchaseDate!;
      }
      if (result.total != null) {
        _price.text = result.total!.toStringAsFixed(2);
      }
      if (result.itemLines.isNotEmpty) {
        final extras = result.itemLines.take(4).join('; ');
        _notes.text = _notes.text.trim().isEmpty
            ? extras
            : '${_notes.text.trim()}\n$extras';
      }
       if (result.note != null) {
        if (_notes.text.trim().isEmpty) {
          _notes.text = result.note!;
        } else {
          _notes.text = '${_notes.text.trim()}\n${result.note}';
        }
      }
      _autoFillWarrantyDefaults();
    });
    gfHaptic(type: GFHaptic.medium);
  }

  Future<void> _scanLabel() async {
    final result = await Navigator.of(context).push<LabelScanResult>(
      MaterialPageRoute(builder: (_) => const LabelScanScreen()),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.serialNumber != null && _serial.text.trim().isEmpty) {
        _serial.text = result.serialNumber!;
      }
    });
    gfHaptic(type: GFHaptic.medium);
  }

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _model, _barcode, _serial, _price, _seller,
      _sellerAddress, _commercialMonths, _commercialProvider,
      _extensionMonths, _extensionProvider, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _startScan() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (result == null || !mounted) return;
    setState(() {
      _applyScan(result);
      _stage =
          result.entry != null ? _Stage.confirm : _Stage.form;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Data di acquisto',
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();

    double? price;
    final priceText = _price.text.trim().replaceAll(',', '.');
    if (priceText.isNotEmpty) {
      price = double.tryParse(priceText);
    }

    final now = DateTime.now();
    final product = Product(
      id: widget.product?.id ?? newId(),
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      category: _category,
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      serialNumber:
          _serial.text.trim().isEmpty ? null : _serial.text.trim(),
      purchaseDate: _purchaseDate,
      price: price,
      seller: _seller.text.trim(),
      sellerAddress:
          _sellerAddress.text.trim().isEmpty ? null : _sellerAddress.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      commercialWarrantyMonths: int.tryParse(_commercialMonths.text.trim()),
      commercialWarrantyProvider: _commercialProvider.text.trim().isEmpty
          ? null
          : _commercialProvider.text.trim(),
      extensionWarrantyMonths: int.tryParse(_extensionMonths.text.trim()),
      extensionWarrantyProvider: _extensionProvider.text.trim().isEmpty
          ? null
          : _extensionProvider.text.trim(),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.product != null) {
      product.timeline.addAll(widget.product!.timeline);
      product.attachments.addAll(widget.product!.attachments);
      await state.updateProduct(product);
    } else {
      product.timeline.add(TimelineEvent(
        id: newId(),
        type: TimelineEventType.acquisto,
        date: _purchaseDate,
        description: 'Acquisto di ${product.displayName}'
            '${product.seller.isNotEmpty ? ' presso ${product.seller}' : ''}'
            '${product.price != null ? ' per ${product.price!.toStringAsFixed(2)} €' : ''}.',
      ));
      await state.addProduct(product);
      final receiptPath = _receiptPath;
      if (receiptPath != null) {
        try {
          final docsDir = await getApplicationDocumentsDirectory();
          final dir = Directory(
            '${docsDir.path}${Platform.pathSeparator}attachments',
          );
          await dir.create(recursive: true);
          final ext = receiptPath.contains('.')
              ? receiptPath.split('.').last
              : 'jpg';
          final target = '${dir.path}${Platform.pathSeparator}'
              '${product.id}_${newId()}.$ext';
          await File(receiptPath).copy(target);
          await state.addAttachment(
            product.id,
            Attachment(
              id: newId(),
              type: AttachmentType.scontrino,
              title: 'Scontrino',
              filePath: target,
              note: 'Acquisito tramite scansione (OCR).',
            ),
          );
        } catch (_) {}
      }
    }
    gfHaptic(type: GFHaptic.medium);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final stage = _effectiveStage;
    final isEditing = widget.product != null;
    final title = switch (stage) {
      _Stage.choose => 'Aggiungi prodotto',
      _Stage.confirm => 'Prodotto riconosciuto',
      _Stage.form => isEditing ? 'Modifica prodotto' : 'Nuovo prodotto',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (stage) {
        _Stage.choose => _buildChoose(),
        _Stage.confirm => _buildConfirm(),
        _Stage.form => _buildForm(),
      },
    );
  }

  Widget _buildChoose() {
    return GFContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const SizedBox(height: 8),
          Text('Come vuoi aggiungere il prodotto?', style: AppTypography.title),
          const SizedBox(height: 6),
          Text(
            'Scansiona il codice a barre per compilare i dati in automatico '
            'oppure inseriscili a mano.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _ModeCard(
            icon: Icons.qr_code_scanner,
            title: 'Scansiona',
            subtitle: 'Inquadra il codice a barre o il QR del prodotto',
            color: AppColors.primary,
            onTap: _startScan,
          ),
          const SizedBox(height: 14),
          _ModeCard(
            icon: Icons.edit_outlined,
            title: 'Inserisci manualmente',
            subtitle: 'Compila i campi con i dati di acquisto',
            color: AppColors.accent,
            onTap: () => setState(() => _stage = _Stage.form),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConfirm() {
    final entry = _name.text;
    final label = entry.isNotEmpty ? entry : 'Prodotto';
    return GFContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          GFAnimated(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primarySoft),
                boxShadow: [AppShadows.card],
              ),
              child: Column(
                children: [
                  GFAvatar(
                    icon: gfCategoryIcon(_category),
                    color: AppColors.primary,
                    size: 84,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.title,
                  ),
                  if (_brand.text.isNotEmpty || _model.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [_brand.text, _model.text]
                          .where((s) => s.isNotEmpty)
                          .join(' '),
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ],
                  if (_barcode.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GFStatusBadge(
                      label: _barcode.text,
                      color: AppColors.primary,
                      icon: Icons.barcode_reader,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Prodotto riconosciuto dal catalogo.\n'
                    'Conferma per continuare con i dati di acquisto.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GFPrimaryButton(
            icon: Icons.check_circle_outline,
            label: 'Conferma prodotto',
            onPressed: () => setState(() => _stage = _Stage.form),
          ),
          const SizedBox(height: 8),
          GFGhostButton(
            label: 'Scansiona di nuovo',
            onPressed: _startScan,
          ),
          GFGhostButton(
            label: 'Inserisci manualmente',
            onPressed: () => setState(() => _stage = _Stage.form),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GFContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            GFFormCard(
              title: 'Scontrino',
              icon: Icons.receipt_long_outlined,
              subtitle:
                  'Scansiona lo scontrino per compilare negozio, data e prezzo '
                  'in automatico e conservarlo come allegato.',
              children: [
                if (widget.product != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'La scansione dello scontrino è disponibile in fase di '
                      'inserimento. Per allegare un documento usa la scheda '
                      'Garanzia del prodotto.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                else ...[
                  if (_receiptPath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: GFStatusBadge(
                              label: 'Scontrino acquisito',
                              color: AppColors.success,
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GFGhostButton(
                            label: 'Rimuovi',
                            onPressed: () =>
                                setState(() => _receiptPath = null),
                          ),
                        ],
                      ),
                    ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _scanReceipt,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text(
                        'Scansiona scontrino (negozio, data, totale)'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            GFFormCard(
              title: 'Prodotto',
              icon: Icons.inventory_2_outlined,
              children: [
                if (widget.product == null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _startScan,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scansiona codice a barre'),
                  ),
                if (widget.product == null) ...[
                  const SizedBox(height: 10),
                  GFGhostButton(
                    icon: Icons.search_outlined,
                    label: 'Cerca nel catalogo',
                    onPressed: _lookupCatalog,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nome prodotto *',
                    hintText: 'es. Lavatrice',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brand,
                        decoration: const InputDecoration(labelText: 'Marca'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _model,
                        decoration: const InputDecoration(labelText: 'Modello'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductCategory>(
                  key: ValueKey(_category),
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: ProductCategory.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v ?? ProductCategory.altro),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GFFormCard(
              title: 'Identificazione',
              icon: Icons.confirmation_number_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _barcode,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Codice a barre',
                          prefixIcon: Icon(Icons.barcode_reader),
                        ),
                      ),
                    ),
                    if (widget.product != null)
                      IconButton(
                        onPressed: _startScan,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _serial,
                  decoration: const InputDecoration(
                    labelText: 'Numero seriale',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GFGhostButton(
                    icon: Icons.qr_code_2,
                    label: 'Scansiona etichetta (seriale)',
                    onPressed: _scanLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GFFormCard(
              title: 'Acquisto',
              icon: Icons.receipt_outlined,
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data di acquisto *',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_purchaseDate),
                      style: AppTypography.body,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Prezzo (€)',
                          prefixIcon: Icon(Icons.euro),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _seller,
                        decoration: const InputDecoration(
                          labelText: 'Negozio *',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Obbligatorio'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sellerAddress,
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo del negozio',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GFFormCard(
              title: 'Garanzie',
              icon: Icons.workspace_premium_outlined,
               subtitle:
                   'La garanzia legale di 24 mesi è applicata automaticamente. '
                   'Per la garanzia commerciale trovi un suggerimento in base '
                   'alla categoria: verifica le condizioni del produttore.',
               children: [
                 Row(
                   children: [
                     Expanded(
                       child: TextFormField(
                         controller: _commercialMonths,
                         keyboardType: TextInputType.number,
                         decoration: InputDecoration(
                           labelText: 'Garanzia commerciale (mesi)',
                           prefixIcon: Icon(Icons.workspace_premium_outlined),
                            helperText: 'Suggerito ${_defaultCommercialMonths(_category)} mesi* '
                                '— verifica le condizioni del prodotto',
                         ),
                       ),
                     ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _commercialProvider,
                        decoration:
                            const InputDecoration(labelText: 'Produttore'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _extensionMonths,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estensione (mesi)',
                          prefixIcon: Icon(Icons.add_chart),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _extensionProvider,
                        decoration: const InputDecoration(
                          labelText: 'Fornitore estensione',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GFFormCard(
              title: 'Note',
              icon: Icons.notes_outlined,
              children: [
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note / annotazioni',
                    hintText: 'es. scontrino conservato in portafoglio',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GFPrimaryButton(
              icon: Icons.check,
              label: widget.product != null ? 'Salva modifiche' : 'Salva prodotto',
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GFScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}