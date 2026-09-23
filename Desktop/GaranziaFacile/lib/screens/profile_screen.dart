import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'legal_info_screen.dart';
import '../services/notification_service.dart';
import '../models/warranty.dart';
import '../services/warranty_service.dart';
import '../models/premium_plan.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gf/gf_buttons.dart';
import '../widgets/gf/gf_foundation.dart';
import '../widgets/gf/gf_motion.dart';
import '../widgets/gf/gf_section.dart';
import 'advice_chat_screen.dart';
import 'archive_screen.dart';
import 'claims_center_screen.dart';
import 'pre_purchase_screen.dart';
import 'warranty_calendar_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final warranty = WarrantyService();

    var active = 0;
    for (final p in state.products) {
      if (warranty.worstStatus(p) == WarrantyStatus.active) active++;
    }
    final sentClaims = state.claims.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: GFContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            const SizedBox(height: 8),
            _ProfileHeader(
              products: state.products.length,
              active: active,
              claims: sentClaims,
            ),
            GFSectionHeader(
              title: 'Protezione legale',
              subtitle: 'Garanzia legale di conformità',
            ),
            GFInfoCard(
              icon: Icons.gavel_outlined,
              title: '24 mesi automatici',
              subtitle:
                  'Per legge, ogni acquisto presso un venditore professionale '
                  'è coperto da garanzia di conformità di 24 mesi '
                  '(art. 128-135 del Codice del consumo).',
            ),
            GFSectionHeader(title: 'Approfondimenti'),
            _LinkTile(
              icon: Icons.shield_outlined,
              title: 'Garanzia legale e commerciale',
              subtitle: 'Le differenze in parole semplici',
              onTap: () => _showInfo(
                context,
                'Le garanzie',
                [
                  for (final t in WarrantyType.values)
                    '${t.label} — ${t.description}',
                  'Le garanzie si sommano: quella legale fa capo al venditore, '
                      'quella commerciale al produttore.',
                ],
              ),
            ),
            _LinkTile(
              icon: Icons.description_outlined,
              title: 'Art. 128-135 Codice del consumo',
              subtitle: 'Conformità, rimedi e termini',
              onTap: () => _showInfo(
                context,
                'Codice del consumo',
                [
                  'Il venditore risponde dei difetti di conformità che si '
                      'manifestano entro 24 mesi dalla consegna.',
                  'Il rimedio prioritario è la riparazione; in alternativa '
                      'sostituzione, riduzione del prezzo o risoluzione.',
                  'Difetti comparsi nei primi 12 mesi: il difetto si presume '
                      'esistente alla consegna, tocca al venditore dimostrare il contrario.',
                ],
              ),
            ),
            _LinkTile(
              icon: Icons.timeline_outlined,
              title: 'Come funziona il reclamo',
              subtitle: 'Dal problema alla lettera',
              onTap: () => _showInfo(
                context,
                'Il percorso',
                [
                  'Apri il prodotto e usa “Segnala problema”.',
                  'Il generatore crea una lettera formale con i riferimenti '
                      'di legge.',
                  'Invia la comunicazione al venditore tramite email o '
                      'condividila (PEC o raccomandata).',
                  'Tieni traccia di risposte e scadenze nella timeline del prodotto.',
                ],
              ),
            ),
            GFSectionHeader(title: 'Strumenti'),
            _LinkTile(
              icon: Icons.assistant_outlined,
              title: 'Cosa posso fare?',
              subtitle: 'Consigli personalizzati sui tuoi acquisti',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdviceChatScreen()),
              ),
            ),
            _LinkTile(
              icon: Icons.health_and_safety_outlined,
              title: 'Verifica pre-acquisto',
              subtitle: 'Controlla cosa ti spetta prima di comprare',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrePurchaseScreen()),
              ),
            ),
            _LinkTile(
              icon: Icons.folder_outlined,
              title: 'Archivio documenti',
              subtitle: 'Tutti gli allegati in un unico posto',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              ),
            ),
            _LinkTile(
              icon: Icons.calendar_month_outlined,
              title: 'Calendario garanzie',
              subtitle: 'Le scadenze mese per mese',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const WarrantyCalendarScreen()),
              ),
            ),
            _LinkTile(
              icon: Icons.mark_email_unread_outlined,
              title: 'Centro reclami',
              subtitle:
                  'Stato di tutte le comunicazioni inviate',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ClaimsCenterScreen()),
              ),
            ),
            _LinkTile(
              icon: Icons.gavel_outlined,
              title: 'Informazioni Legali e Note',
              subtitle: 'Privacy, condizioni d’uso e responsabilità',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LegalInfoScreen()),
              ),
            ),
            GFSectionHeader(title: 'I tuoi dati'),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PlanTier.free.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      PlanTier.free.icon,
                      color: PlanTier.free.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Piano attuale: ${PlanTier.free.label}',
                          style: AppTypography.label.copyWith(
                            color: PlanTier.free.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tutte le funzionalità disponibili. Il Premium arriverà in futuro.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _LinkTile(
              icon: Icons.ios_share_outlined,
              title: 'Esporta backup',
              subtitle: 'Salva i dati in un file JSON',
              onTap: () => _export(context),
            ),
            _LinkTile(
              icon: Icons.settings_backup_restore_outlined,
              title: 'Importa backup',
              subtitle: 'Ripristina i dati da un file JSON',
              onTap: () => _import(context),
            ),
              _LinkTile(
              icon: Icons.delete_forever_outlined,
              title: 'Elimina tutti i dati',
              subtitle: 'Cancellazione definitiva e irreversibile',
              onTap: () => _showDeleteConfirmation(context),
            ),
            const SizedBox(height: 14),
            GFSectionHeader(title: 'Supporto'),
            _LinkTile(
              icon: Icons.feedback_outlined,
              title: 'Invia feedback',
              subtitle: 'Segnala bug, suggerimenti o richieste funzioni',
              onTap: () => _sendFeedback(),
            ),
            const SizedBox(height: 24),
            _VersionBadge(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final state = context.read<AppState>();
    final json = state.exportJson();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'garanzia_facile_backup_$timestamp.json';
    try {
      final dir = await getExternalStoragePublicDirectory();
      if (dir == null) throw Exception('Directory non disponibile');
      final path = '${dir.path}${_separator()}$filename';
      final file = File(path);
      await file.writeAsString(json, flush: true);
      if (context.mounted) {
        gfHaptic(type: GFHaptic.medium);
        gfSnack(context, 'Backup salvato in:\n${file.path}');
      }
    } catch (e) {
      if (context.mounted) {
        gfSnack(context, 'Salvataggio fallito: $e', success: false);
      }
    }
  }

  String _separator() => Platform.pathSeparator;

  static Future<Directory?> getExternalStoragePublicDirectory() async {
    try {
      return await getExternalStorageDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<void> _import(BuildContext context) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return;
    final path = files.first.path;
    if (path == null) return;
    try {
      final content = await File(path).readAsString();
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importa backup'),
          content: const Text(
            'Questo sovrascriverà tutti i dati esistenti con quelli del backup. '
            'Assicurati di aver eseguito un backup recente. Continuare?',
          ),
          actions: [
            GFGhostButton(
              label: 'Annulla',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            GFPrimaryButton(
              expanded: false,
              label: 'Importa',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final state = context.read<AppState>();
      final before = state.products.length;
      await state.importBackup(content);
      if (!context.mounted) return;
      gfHaptic(type: GFHaptic.medium);
      gfSnack(
        context,
        before == 0
            ? 'Backup ripristinato: ${state.products.length} prodotti.'
            : 'Dati sostituiti con il backup importato.',
      );
    } catch (_) {
      if (context.mounted) {
        gfSnack(context, 'File non valido: impossibile importare il backup.',
            success: false, icon: Icons.error_outline);
      }
    }
  }

  Future<void> _sendFeedback() async {
    const subject = 'Feedback GaranziaFacile';
    final body = 'Ciao, sto usando GaranziaFacile e voglio dirti...';
    final email = Uri.encodeFull('mailto:privacy@garanziafacile.it?subject=$subject&body=$body');
    await launchUrl(Uri.parse(email));
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina tutti i dati'),
        content: const Text(
          'Sei sicuro di voler procedere? Questa azione cancellerà definitivamente ed in modo irreversibile tutti i tuoi dati salvati sul dispositivo (prodotti, ricevute, allegati, reclami e impostazioni), in conformità con il GDPR (Art. 17) e le linee guida Google Play. L\u2019applicazione verrà reimpostata allo stato iniziale.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina Tutto'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      gfHaptic(type: GFHaptic.medium);
      final appState = context.read<AppState>();
      final notificationService = context.read<NotificationService>();
      await notificationService.cancelAll();
      await appState.deleteAccountAndAllData();
      if (context.mounted) {
        gfSnack(context, 'Tutti i dati sono stati eliminati definitivamente.');
      }
    }
  }

  Future<void> _showInfo(
    BuildContext context,
    String title,
    List<String> bullets,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final b in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(b, style: AppTypography.body),
                ),
            ],
          ),
        ),
        actions: [
          GFGhostButton(
            label: 'Chiudi',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.products,
    required this.active,
    required this.claims,
  });

  final int products;
  final int active;
  final int claims;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
        boxShadow: [AppShadows.soft],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDeep],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'GF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Consumatore', style: AppTypography.title),
          const SizedBox(height: 4),
          Text(
            'Le tue garanzie al sicuro, sempre.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stat(products, 'Prodotti'),
              _divider(),
              _stat(active, 'Garanzie attive'),
              _divider(),
              _stat(claims, 'Reclami'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(int value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 34, color: AppColors.outline);
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GFScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.label),
                  const SizedBox(height: 2),
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

class _VersionBadge extends StatefulWidget {
  const _VersionBadge();

  @override
  State<_VersionBadge> createState() => _VersionBadgeState();
}

class _VersionBadgeState extends State<_VersionBadge> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'GaranziaFacile · v$_version',
        style: AppTypography.caption.copyWith(fontSize: 11),
      ),
    );
  }
}