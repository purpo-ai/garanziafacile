import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart' as printing;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/enums.dart';
import '../models/product.dart';
import '../services/claim_generator.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gf/gf_badge.dart';
import '../widgets/gf/gf_buttons.dart';
import '../widgets/gf/gf_foundation.dart';
import '../widgets/gf/gf_icons.dart';
import '../widgets/gf/gf_motion.dart';

class ClaimScreen extends StatefulWidget {
  final String productId;
  final Claim? claim;
  final IssueType? initialIssue;
  final ClaimRequest? initialRequest;
  final String? initialDescription;
  final DateTime? initialDefectDate;
  const ClaimScreen({
    super.key,
    required this.productId,
    this.claim,
    this.initialIssue,
    this.initialRequest,
    this.initialDescription,
    this.initialDefectDate,
  });

  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _description;
  ClaimRequest _request = ClaimRequest.riparazione;
  IssueType _issue = IssueType.difettoso;
  DateTime? _defectDate;
  String _saleReference = 'Prova d\'acquisto';
  int _replyDays = 15;
  String? _generated;
  late Claim? _currentClaim;
  bool _verifiedInfo = false;
  bool _showFeedback = false;
  bool _generationSuccess = false;

  bool get _isExisting => widget.claim != null;

  @override
  void initState() {
    super.initState();
    _currentClaim = widget.claim;
    _name = TextEditingController();
    _address = TextEditingController();
    _description = TextEditingController(
        text: widget.initialDescription ?? widget.claim?.whatHappened ?? '');
    _request = widget.initialRequest ??
        widget.claim?.request ??
        ClaimRequest.riparazione;
    _issue = widget.initialIssue ?? widget.claim?.issueType ?? IssueType.difettoso;
    _defectDate = widget.initialDefectDate ?? widget.claim?.defectOccurredAt;
    if (_isExisting) {
      _generated = widget.claim!.letterBody;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  void _generate() {
    final product = context.read<AppState>().productById(widget.productId);
    if (product == null) return;
    final draft = ClaimDraft(
      seller: product.seller,
      consumerName: _name.text.trim(),
      consumerAddress: _address.text.trim(),
      saleReference: _saleReference,
      request: _request,
      whatHappened: _description.text.trim().isEmpty
          ? 'Il prodotto presenta un difetto di conformità.'
          : _description.text.trim(),
      defectOccurredAt: _defectDate,
      replyDays: _replyDays,
    );
    setState(() {
      _generated = ClaimGenerator().generate(product, draft);
      _generationSuccess = true;
    });
    gfHaptic(type: GFHaptic.medium);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _generationSuccess = false);
    });
  }

  Product? get product =>
      context.read<AppState>().productById(widget.productId);

  Future<void> _generatePdf() async {
    if (_generated == null) _generate();
    final p = product;
    if (p == null || _generated == null) return;
    final subject = ClaimGenerator().emailSubject(
      p,
      ClaimDraft(
        seller: p.seller,
        request: _request,
        whatHappened: _description.text,
      ),
    );
    gfHaptic(type: GFHaptic.medium);
    try {
      final bytes = await PdfService().letterPdf(
        'Reclamo – ${p.displayName}',
        'Allegato: $subject\n\n$_generated',
      );
      if (_isExisting) {
        await _recordCommunication(CommunicationMethod.pdf, subject);
      }
      await _sharePdf(subject, p.displayName, bytes);
    } catch (_) {
      await _shareText(subject, _generated!);
    }
  }

  Future<void> _saveAsBozza() async {
    if (_generated == null) _generate();
    final state = context.read<AppState>();
    final claim = Claim(
      id: _isExisting ? _currentClaim!.id : newId(),
      productId: widget.productId,
      issueType: _issue,
      request: _request,
      whatHappened: _description.text,
      defectOccurredAt: _defectDate,
      letterBody: _generated ?? '',
      status: _isExisting ? _currentClaim!.status : ClaimStatus.generato,
      sentAt: _isExisting ? _currentClaim!.sentAt : null,
      communications:
          _isExisting ? _currentClaim!.communications : const [],
      createdAt: _isExisting ? _currentClaim!.createdAt : DateTime.now(),
    );
    if (_isExisting) {
      await state.updateClaim(claim);
    } else {
      await state.addClaim(claim);
    }
    _currentClaim = claim;
    if (mounted) {
      gfSnack(context, 'Reclamo salvato come bozza.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _recordCommunication(
    CommunicationMethod method,
    String subject,
  ) async {
    if (!_isExisting || _currentClaim == null) return;
    final state = context.read<AppState>();
    final communication = ClaimCommunication(
      id: newId(),
      method: method,
      subject: subject,
      sentAt: DateTime.now(),
    );
    final updated = _currentClaim!.copyWith(
      communications: [..._currentClaim!.communications, communication],
    );
    await state.updateClaim(updated);
    if (mounted) setState(() => _currentClaim = updated);
  }

  Future<void> _share() async {
    final product = context.read<AppState>().productById(widget.productId);
    if (product == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Condividi reclamo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verifica prima di condividere:'),
            const SizedBox(height: 8),
            _buildReviewRow('Venditore', product.seller),
            _buildReviewRow('Prodotto', product.displayName),
            _buildReviewRow('Data acquisto',
                DateFormat('dd/MM/yyyy').format(product.purchaseDate)),
            if (product.serialNumber != null)
              _buildReviewRow('Seriale', product.serialNumber!),
            _buildReviewRow('Richiesto', _request.label),
            const SizedBox(height: 8),
            const Text(
              'Il destinatario riceverà il testo della comunicazione. '
              'Assicurati che i dati siano corretti.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Condividi'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final subject = ClaimGenerator().emailSubject(
      product,
      ClaimDraft(
        seller: product.seller,
        request: _request,
        whatHappened: _description.text,
      ),
    );

    final state = context.read<AppState>();
    final now = DateTime.now();
    final communication = ClaimCommunication(
      id: newId(),
      method: CommunicationMethod.share,
      subject: subject,
      sentAt: now,
    );
    if (!mounted) return;
    if (!_isExisting) {
      final claim = Claim(
        id: newId(),
        productId: widget.productId,
        issueType: _issue,
        request: _request,
        whatHappened: _description.text,
        defectOccurredAt: _defectDate,
        letterBody: _generated!,
        status: ClaimStatus.inviato,
        createdAt: DateTime.now(),
        sentAt: now,
        communications: [communication],
      );
      await state.addClaim(claim);
      _currentClaim = claim;
      await _afterSend(product);
    } else {
      final previousStatus = _currentClaim!.status;
      final updated = _currentClaim!.copyWith(
        status: ClaimStatus.inviato,
        sentAt: now,
        communications: [..._currentClaim!.communications, communication],
      );
      await state.updateClaim(updated);
      if (mounted) setState(() => _currentClaim = updated);
      if (previousStatus == ClaimStatus.bozza) {
        await _afterSend(product);
      }
    }

    try {
      final name = product.displayName;
      final bytes = await PdfService().letterPdf(
        'Reclamo – $name',
        'Allegato: $subject\n\n$_generated',
      );
      await _sharePdf(subject, product.displayName, bytes);
    } catch (_) {
      await _shareText(subject, _generated!);
    }
  }

  Future<void> _sendEmail() async {
    if (_generated == null) _generate();
    final product = context.read<AppState>().productById(widget.productId);
    if (product == null || _generated == null) return;
    final subject = ClaimGenerator().emailSubject(
      product,
      ClaimDraft(
        seller: product.seller,
        request: _request,
        whatHappened: _description.text,
      ),
    );
    gfHaptic(type: GFHaptic.selection);
    if (_isExisting) {
      await _recordCommunication(CommunicationMethod.email, subject);
    }
    await _shareText(subject, _generated!);
  }

  Widget _buildReviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text('$label:', style: AppTypography.caption),
            ),
            Expanded(
              child: Text(value, style: AppTypography.body),
            ),
          ],
        ),
      );

  Future<void> _sharePdf(
    String subject,
    String productName,
    Uint8List bytes,
  ) async {
    try {
      await printing.Printing.sharePdf(
        bytes: bytes,
        filename: 'reclamo_${productName.replaceAll(' ', '_')}.pdf',
      );
    } catch (_) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}${Platform.pathSeparator}'
        'reclamo_${productName.replaceAll(' ', '_')}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: subject,
        sharePositionOrigin: _shareOrigin(),
      ));
    }
  }

  Future<void> _shareText(String subject, String body) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '$subject\n\n$body',
        sharePositionOrigin: _shareOrigin(),
      ),
    );
  }

  Rect _shareOrigin() {
    final box = context.findRenderObject() as RenderBox?;
    return box == null
        ? const Rect.fromLTWH(0, 0, 1, 1)
        : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _afterSend(Product product) async {
    final state = context.read<AppState>();
    await state.addTimelineEvent(
      widget.productId,
      TimelineEvent(
        id: newId(),
        type: TimelineEventType.reclamoInviato,
        date: DateTime.now(),
        description: 'Reclamo inviato al venditore (${_request.label}).',
      ),
    );
    await state.addNotification(NotificationItem(
      id: newId(),
      title: 'Reclamo inviato',
      message: 'La richiesta di ${_request.label.toLowerCase()} per '
          '${product.displayName} è stata inviata.',
      productId: product.id,
      createdAt: DateTime.now(),
    ));
    setState(() => _showFeedback = true);
  }

  void _updateStatus(ClaimStatus status) {
    final state = context.read<AppState>();
    if (!_isExisting || _currentClaim == null) return;
    final updated = _currentClaim!.copyWith(status: status);
    state.updateClaim(updated);
    if (mounted) setState(() => _currentClaim = updated);
  }

  @override
  Widget build(BuildContext context) {
    final product =
        context.watch<AppState>().productById(widget.productId);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reclamo')),
        body: Center(
          child: Text('Prodotto non trovato',
              style: AppTypography.body.copyWith(color: AppColors.textMuted)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isExisting ? 'Dettaglio reclamo' : 'Genera reclamo'),
        actions: [
          if (_isExisting)
            PopupMenuButton<ClaimStatus>(
              tooltip: 'Stato',
              onSelected: _updateStatus,
              itemBuilder: (_) => ClaimStatus.values
                  .map((s) => PopupMenuItem(
                        value: s,
                        child: Text(gfClaimLabel(s)),
                      ))
                  .toList(),
            ),
        ],
      ),
      body: GFContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _DocHeader(
              product: product,
              existing: _isExisting,
              status: _currentClaim?.status,
            ),
            const SizedBox(height: 16),
            _Section(
              icon: Icons.storefront_outlined,
              title: 'Destinatario',
              children: [
                _row(context, product.seller.isEmpty ? 'Venditore' : product.seller,
                    product.sellerAddress ?? 'Riferimento per la garanzia legale'),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              icon: Icons.report_problem_outlined,
              title: 'Problema',
              children: [
                DropdownButtonFormField<IssueType>(
                  initialValue: _issue,
                  decoration: const InputDecoration(
                    labelText: 'Tipo problema',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  items: IssueType.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _issue = v ?? _issue),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione del problema *',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              icon: Icons.request_quote_outlined,
              title: 'Richiesta',
              children: [
                DropdownButtonFormField<ClaimRequest>(
                  initialValue: _request,
                  decoration: const InputDecoration(
                    labelText: 'Cosa chiedi',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                  items: ClaimRequest.values
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _request = v ?? _request),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              icon: Icons.rule_outlined,
              title: 'Termini',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _saleReference,
                        decoration: const InputDecoration(
                          labelText: 'Documento acquisto',
                          prefixIcon: Icon(Icons.receipt_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'scontrino', child: Text('Scontrino')),
                          DropdownMenuItem(
                              value: 'fattura', child: Text('Fattura')),
                          DropdownMenuItem(
                              value: 'scontrino e fattura',
                              child: Text('Scontrino e fattura')),
                        ],
                        onChanged: (v) => setState(
                            () => _saleReference = v ?? 'scontrino'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _replyDays,
                        decoration: const InputDecoration(
                          labelText: 'Termine risposta',
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10 giorni')),
                          DropdownMenuItem(value: 15, child: Text('15 giorni')),
                          DropdownMenuItem(value: 30, child: Text('30 giorni')),
                        ],
                        onChanged: (v) =>
                            setState(() => _replyDays = v ?? 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (!_isExisting)
              _Section(
                icon: Icons.person_outline,
                title: 'I tuoi dati (facoltativo)',
                subtitle:
                    'Rafforza la comunicazione: il destinatario saprà a chi rispondere.',
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Nome e cognome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: 'Indirizzo / recapiti',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                ],
              ),
            if (_isExisting) ...[
              const SizedBox(height: 14),
              _Section(
                icon: Icons.info_outline,
                title: 'Dati reclamo',
                children: [
                  _row(context, 'Tipo', _currentClaim!.issueType.label),
                  _row(context, 'Richiesta', _currentClaim!.request.label),
                  if (_currentClaim!.defectOccurredAt != null)
                    _row(
                      context,
                      'Difetto dal',
                      _fmt(_currentClaim!.defectOccurredAt!),
                    ),
                  _row(context, 'Stato',
                      gfClaimLabel(_currentClaim!.status)),
                  if (_currentClaim!.sentAt != null)
                    _row(context, 'Inviato il', _fmt(_currentClaim!.sentAt!)),
                ],
              ),
              const SizedBox(height: 14),
              _Section(
                icon: Icons.outbox_outlined,
                title: 'Tracking comunicazioni',
                subtitle:
                    'Ogni invio di questa comunicazione viene registrato.',
                children: [
                  if (_currentClaim!.communications.isEmpty)
                    Text(
                      'Nessuna comunicazione registrata per questo reclamo.',
                      style: AppTypography.caption,
                    )
                  else
                    for (final comm in _currentClaim!.communications)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            GFAvatar(
                              icon: comm.method == CommunicationMethod.email
                                  ? Icons.mail_outline
                                  : comm.method == CommunicationMethod.pdf
                                      ? Icons.picture_as_pdf_outlined
                                      : Icons.ios_share_outlined,
                              color: AppColors.primary,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${comm.method.label} · ${_fmt(comm.sentAt)}',
                                    style: AppTypography.label,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comm.subject,
                                    style: AppTypography.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _Section(
              icon: Icons.attachment_outlined,
              title: 'Allegati',
              subtitle:
                  'Allega scontrino, fattura o foto dal prodotto prima dell\u2019invio.',
              children: [
                if (product.attachments.isEmpty)
                  Text(
                    '${product.displayName} non ha ancora documenti allegati.',
                    style: AppTypography.caption,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.attachments
                        .map(
                          (a) => GFStatusBadge(
                            label: a.title,
                            color: AppColors.primary,
                            compact: true,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_generationSuccess)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  final scale = (1 - value) * 0 + value * value * 0.2 + 0.8;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bozza generata con successo',
                        style: AppTypography.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const _LetterLabel(),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _LetterPreview(key: ValueKey(_generated), text: _generated),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prima di procedere',
                    style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDeep),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stai per generare una bozza di comunicazione. Controlla attentamente dati, destinatario, date e contenuto. GaranziaFacile non garantisce l\u2019esito della richiesta.',
                    style: AppTypography.caption.copyWith(fontSize: 11.5, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    value: _verifiedInfo,
                    title: Text(
                      'Ho verificato le informazioni e desidero generare la bozza.',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 11.5),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    dense: true,
                    onChanged: (v) => setState(() => _verifiedInfo = v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GFPrimaryButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Genera PDF',
              onPressed: _verifiedInfo ? (_generated == null ? _generate : _generatePdf) : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GFSecondaryButton(
                    icon: Icons.ios_share_outlined,
                    label: 'Condividi',
                    onPressed: _verifiedInfo ? _share : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GFSecondaryButton(
                    icon: Icons.mail_outline,
                    label: 'Invia email',
                    onPressed: _verifiedInfo ? _sendEmail : null,
                  ),
                ),
              ],
            ),
            if (!_isExisting) ...[
              const SizedBox(height: 8),
              Center(
                child: GFGhostButton(
                  label: 'Salva come bozza',
                  onPressed: _verifiedInfo ? _saveAsBozza : null,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_showFeedback) _FeedbackSection(
              onFeedback: (useful) => _submitFeedback(useful, product),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(bool useful, Product product) async {
    final subject = 'Feedback GaranziaFacile — reclamo ${product.displayName}';
    final body = useful
        ? 'Il generatore di reclami mi è stato utile per ${product.displayName}.'
        : 'Il generatore di reclami non mi è stato utile per ${product.displayName}. Cosa migliorare: ';

    final email = Uri.encodeFull('mailto:privacy@garanziafacile.it?subject=$subject&body=$body');
    final launched = await launchUrl(Uri.parse(email));
    if (launched && mounted) {
      if (context.mounted) {
        gfSnack(context, 'Grazie! Il tuo feedback è stato inviato.');
      }
    }
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  AppTypography.labelMuted.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.onFeedback});

  final ValueChanged<bool> onFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ti è stato utile questo reclamo?',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Aiutaci a migliorare GaranziaFacile.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GFSecondaryButton(
                  icon: Icons.thumb_up_outlined,
                  label: 'Sì',
                  onPressed: () => onFeedback(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GFSecondaryButton(
                  icon: Icons.thumb_down_outlined,
                  label: 'No',
                  onPressed: () => onFeedback(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocHeader extends StatelessWidget {
  const _DocHeader({
    required this.product,
    required this.existing,
    this.status,
  });

  final Product product;
  final bool existing;
  final ClaimStatus? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDeep, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing ? 'Documento reclamo' : 'Bozza reclamo',
                  style: AppTypography.heading.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  product.displayName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (status != null)
            GFStatusBadge(
              label: gfClaimLabel(status!),
              color: gfClaimColor(status!),
              compact: true,
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppTypography.heading),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: AppTypography.caption),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _LetterLabel extends StatelessWidget {
  const _LetterLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Bozza della comunicazione', style: AppTypography.heading),
        const Spacer(),
        Text('Pronta per l\u2019invio', style: AppTypography.caption),
      ],
    );
  }
}

class _LetterPreview extends StatelessWidget {
  const _LetterPreview({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
        ),
        child: Text(
          'Premi “Genera PDF” per creare la bozza di lettera formale '
          'con i riferimenti normativi del Codice del consumo.',
          style: AppTypography.body.copyWith(color: AppColors.textMuted),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineStrong),
        boxShadow: [AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Bozza di comunicazione basata sulle disposizioni del Codice del Consumo.',
            style: AppTypography.label.copyWith(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 4),
          Text(
            'La bozza è generata automaticamente sulla base delle informazioni inserite. Verifica sempre i dati, il destinatario e la situazione concreta prima dell\u2019invio.',
            style: AppTypography.caption.copyWith(fontSize: 11.5, height: 1.3),
          ),
          const Divider(height: 20),
          SelectableText(
            text!,
            style: AppTypography.body.copyWith(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}