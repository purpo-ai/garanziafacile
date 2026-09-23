import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/warranty.dart';
import '../../theme/app_theme.dart';

/// Colore di stato coerente per le garanzie.
Color gfStatusColor(WarrantyStatus status) {
  switch (status) {
    case WarrantyStatus.active:
      return AppColors.success;
    case WarrantyStatus.expiringSoon:
      return AppColors.warning;
    case WarrantyStatus.expired:
      return AppColors.danger;
  }
}

String gfStatusLabel(WarrantyStatus status) {
  switch (status) {
    case WarrantyStatus.active:
      return 'Attiva';
    case WarrantyStatus.expiringSoon:
      return 'In scadenza';
    case WarrantyStatus.expired:
      return 'Scaduta';
  }
}

/// Colore di stato coerente per i reclami.
Color gfClaimColor(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.bozza:
      return AppColors.textMuted;
    case ClaimStatus.generato:
      return AppColors.accent;
    case ClaimStatus.inviato:
      return AppColors.primary;
    case ClaimStatus.inAttesa:
      return AppColors.warning;
    case ClaimStatus.rispostaRicevuta:
      return AppColors.warning;
    case ClaimStatus.risolta:
      return AppColors.success;
  }
}

String gfClaimLabel(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.bozza:
      return 'Bozza';
    case ClaimStatus.generato:
      return 'Generato';
    case ClaimStatus.inviato:
      return 'Inviato';
    case ClaimStatus.inAttesa:
      return 'In attesa';
    case ClaimStatus.rispostaRicevuta:
      return 'Risposta ricevuta';
    case ClaimStatus.risolta:
      return 'Risolto';
  }
}

IconData gfCategoryIcon(ProductCategory category) {
  switch (category) {
    case ProductCategory.telefonia:
      return Icons.smartphone;
    case ProductCategory.elettrodomestici:
      return Icons.kitchen;
    case ProductCategory.informatica:
      return Icons.laptop_mac;
    case ProductCategory.elettronica:
      return Icons.devices;
    case ProductCategory.audioVideo:
      return Icons.tv;
    case ProductCategory.mobili:
      return Icons.chair;
    case ProductCategory.abbigliamento:
      return Icons.checkroom;
    case ProductCategory.giocattoli:
      return Icons.toys;
    case ProductCategory.altro:
      return Icons.category;
  }
}

IconData gfWarrantyIcon(WarrantyType type) {
  switch (type) {
    case WarrantyType.legal:
      return Icons.gavel_outlined;
    case WarrantyType.commercial:
      return Icons.factory_outlined;
    case WarrantyType.assistance:
      return Icons.build_circle_outlined;
    case WarrantyType.extension:
      return Icons.add_chart;
  }
}

IconData gfTimelineIcon(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.acquisto:
      return Icons.shopping_bag_outlined;
    case TimelineEventType.difettoSegnalato:
      return Icons.report_problem_outlined;
    case TimelineEventType.reclamoInviato:
      return Icons.send_outlined;
    case TimelineEventType.rispostaVenditore:
      return Icons.mark_email_read_outlined;
    case TimelineEventType.consegnaRiparazione:
      return Icons.build_outlined;
    case TimelineEventType.riparazioneEffettuata:
      return Icons.handyman_outlined;
    case TimelineEventType.sostituzione:
      return Icons.swap_horiz;
    case TimelineEventType.rimborso:
      return Icons.payments_outlined;
    case TimelineEventType.altro:
      return Icons.event_note_outlined;
  }
}

/// Colore assegnato a ciascun tipo di evento timeline.
Color gfTimelineColor(TimelineEventType type) {
  switch (type) {
    case TimelineEventType.acquisto:
      return AppColors.primary;
    case TimelineEventType.difettoSegnalato:
      return AppColors.warning;
    case TimelineEventType.reclamoInviato:
      return AppColors.primary;
    case TimelineEventType.rispostaVenditore:
      return AppColors.accent;
    case TimelineEventType.consegnaRiparazione:
      return AppColors.primary;
    case TimelineEventType.riparazioneEffettuata:
      return AppColors.success;
    case TimelineEventType.sostituzione:
      return AppColors.accent;
    case TimelineEventType.rimborso:
      return AppColors.success;
    case TimelineEventType.altro:
      return AppColors.textMuted;
  }
}

/// Emoji doc friendly per categoria documento (richieste dal design).
String gfAttachmentEmoji(AttachmentType type) {
  switch (type) {
    case AttachmentType.scontrino:
      return '🧾';
     case AttachmentType.fattura:
      return '📄';
    case AttachmentType.ordineOnline:
      return '🛒';
    case AttachmentType.provaPagamento:
      return '💳';
    case AttachmentType.manuale:
      return '📘';
    case AttachmentType.fotoProdotto:
      return '📷';
    case AttachmentType.ricevutaRiparazione:
      return '🛠️';
    case AttachmentType.altro:
      return '📎';
  }
}

IconData gfAttachmentIcon(AttachmentType type) {
  switch (type) {
    case AttachmentType.scontrino:
      return Icons.receipt_long_outlined;
     case AttachmentType.fattura:
      return Icons.description_outlined;
    case AttachmentType.ordineOnline:
      return Icons.shopping_bag_outlined;
    case AttachmentType.provaPagamento:
      return Icons.payment_outlined;
    case AttachmentType.manuale:
      return Icons.menu_book_outlined;
    case AttachmentType.fotoProdotto:
      return Icons.photo_camera_outlined;
    case AttachmentType.ricevutaRiparazione:
      return Icons.assignment_outlined;
    case AttachmentType.altro:
      return Icons.attach_file;
  }
}