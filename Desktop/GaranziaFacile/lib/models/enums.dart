enum ProductCategory {
  elettronica,
  elettrodomestici,
  informatica,
  telefonia,
  audioVideo,
  mobili,
  abbigliamento,
  giocattoli,
  altro;

  String get label {
    switch (this) {
      case ProductCategory.elettronica:
        return 'Elettronica';
      case ProductCategory.elettrodomestici:
        return 'Elettrodomestici';
      case ProductCategory.informatica:
        return 'Informatica';
      case ProductCategory.telefonia:
        return 'Telefonia';
      case ProductCategory.audioVideo:
        return 'Audio / Video';
      case ProductCategory.mobili:
        return 'Mobili';
      case ProductCategory.abbigliamento:
        return 'Abbigliamento';
      case ProductCategory.giocattoli:
        return 'Giocattoli';
      case ProductCategory.altro:
        return 'Altro';
    }
  }
}

enum TimelineEventType {
  acquisto,
  difettoSegnalato,
  reclamoInviato,
  rispostaVenditore,
  consegnaRiparazione,
  riparazioneEffettuata,
  sostituzione,
  rimborso,
  altro;

  String get label {
    switch (this) {
      case TimelineEventType.acquisto:
        return 'Acquisto';
      case TimelineEventType.difettoSegnalato:
        return 'Difetto segnalato';
      case TimelineEventType.reclamoInviato:
        return 'Reclamo inviato';
      case TimelineEventType.rispostaVenditore:
        return 'Risposta venditore';
      case TimelineEventType.consegnaRiparazione:
        return 'Consegnato per riparazione';
      case TimelineEventType.riparazioneEffettuata:
        return 'Riparazione effettuata';
      case TimelineEventType.sostituzione:
        return 'Sostituzione';
      case TimelineEventType.rimborso:
        return 'Rimborso';
      case TimelineEventType.altro:
        return 'Altro';
    }
  }
}

enum IssueType {
  difettoso,
  nonConforme,
  riparazioneNonRiuscita,
  sostituzioneRichiesta,
  rimborso,
  assistenzaInGaranzia,
  altro;

  String get label {
    switch (this) {
      case IssueType.difettoso:
        return 'Prodotto difettoso';
      case IssueType.nonConforme:
        return 'Prodotto non conforme';
      case IssueType.riparazioneNonRiuscita:
        return 'Riparazione non riuscita';
      case IssueType.sostituzioneRichiesta:
        return 'Sostituzione richiesta';
      case IssueType.rimborso:
        return 'Rimborso';
      case IssueType.assistenzaInGaranzia:
        return 'Assistenza in garanzia';
      case IssueType.altro:
        return 'Altro';
    }
  }
}

enum ClaimRequest {
  riparazione,
  sostituzione,
  riduzionePrezzo,
  risoluzione;

  String get label {
    switch (this) {
      case ClaimRequest.riparazione:
        return 'Riparazione';
      case ClaimRequest.sostituzione:
        return 'Sostituzione';
      case ClaimRequest.riduzionePrezzo:
        return 'Riduzione del prezzo';
      case ClaimRequest.risoluzione:
        return 'Risoluzione (rimborso)';
    }
  }
}

enum AttachmentType {
  scontrino,
  fattura,
  ordineOnline,
  provaPagamento,
  manuale,
  fotoProdotto,
  ricevutaRiparazione,
  altro;

  String get label {
    switch (this) {
      case AttachmentType.scontrino:
        return 'Scontrino';
      case AttachmentType.fattura:
        return 'Fattura';
      case AttachmentType.ordineOnline:
        return 'Ordine online';
      case AttachmentType.provaPagamento:
        return 'Prova di pagamento';
      case AttachmentType.manuale:
        return 'Manuale';
      case AttachmentType.fotoProdotto:
        return 'Foto prodotto';
      case AttachmentType.ricevutaRiparazione:
        return 'Ricevuta riparazione';
      case AttachmentType.altro:
        return 'Altro';
    }
  }
}

enum ClaimStatus {
  bozza,
  generato,
  inviato,
  inAttesa,
  rispostaRicevuta,
  risolta;

  String get label {
    switch (this) {
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
}

enum CommunicationMethod {
  email,
  pdf,
  share;

  String get label {
    switch (this) {
      case CommunicationMethod.email:
        return 'Email';
      case CommunicationMethod.pdf:
        return 'PDF';
      case CommunicationMethod.share:
        return 'Condivisione';
    }
  }
}

enum AcquisitionType {
  personal,
  professional;

  String get label {
    switch (this) {
      case AcquisitionType.personal:
        return 'Per uso personale';
      case AcquisitionType.professional:
        return 'Per uso professionale';
    }
  }
}

enum SellerType {
  professional,
  private;

  String get label {
    switch (this) {
      case SellerType.professional:
        return 'Venditore professionista';
      case SellerType.private:
        return 'Privato';
    }
  }
}

enum WarrantySource {
  calculated,
  estimated,
  userEntered,
  unknown;

  String get label {
    switch (this) {
      case WarrantySource.calculated:
        return 'Calcolato';
      case WarrantySource.estimated:
        return 'Stimato';
      case WarrantySource.userEntered:
        return 'Inserito dall\'utente';
      case WarrantySource.unknown:
        return 'Non disponibile';
    }
  }
}