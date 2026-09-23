import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/gf/gf_buttons.dart';
import '../widgets/gf/gf_foundation.dart';
import 'legal_disclaimer_screen.dart';

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  static const _privacyUrl =
      'https://purpo-ai.github.io/garanziafacile/privacy-policy.html';
  static const _supportEmail = 'privacy@garanziafacile.it';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Informazioni legali'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
      ),
      body: GFContent(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Card(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle:
                  'Come raccolgiamo e trattiamo i dati. Tutti i dati restano '
                  'sul tuo dispositivo.',
              action: 'Leggi informativa',
              onAction: () => launchUrl(Uri.parse(_privacyUrl)),
            ),
            const SizedBox(height: 16),
            _Card(
              icon: Icons.description_outlined,
              title: 'Note legali e condizioni',
              subtitle:
                  'GaranziaFacile non fornisce consulenza legale. Le '
                  'informazioni sono di supporto e devono essere verificate.',
              action: 'Leggi disclaimer',
              onAction: () =>
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LegalDisclaimerScreen())),
            ),
            const SizedBox(height: 16),
            _Card(
              icon: Icons.copyright_outlined,
              title: 'Copyright',
              subtitle:
                  'GaranziaFacile — Tutti i diritti riservati. Progetto privato.',
              action: null,
              onAction: null,
            ),
            const SizedBox(height: 16),
            _Card(
              icon: Icons.contact_mail_outlined,
              title: 'Contatti',
              subtitle: 'Per questioni privacy: $_supportEmail',
              action: 'Invia email',
              onAction: () => launchUrl(Uri.parse('mailto:$_supportEmail')),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'GaranziaFacile· v1.0.0',
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
        boxShadow: [AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(title, style: AppTypography.heading.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.caption),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: GFGhostButton(
                label: action!,
                icon: Icons.open_in_browser,
                onPressed: onAction!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
