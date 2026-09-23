import 'package:intl/intl.dart';

import '../models/enums.dart';
import '../models/product.dart';
import 'claim_generator.dart';
import 'warranty_service.dart';

class LegalAdvice {
  final String summary;
  final List<String> warranties;
  final List<String> documentsNeeded;
  final List<String> possibleRequests;
  final List<String> nextSteps;
  final String draftCommunication;
  final String engineVersion;
  final String lastUpdated;
  final List<String> normativeSources;

  const LegalAdvice({
    required this.summary,
    required this.warranties,
    required this.documentsNeeded,
    required this.possibleRequests,
    required this.nextSteps,
    required this.draftCommunication,
    required this.engineVersion,
    required this.lastUpdated,
    required this.normativeSources,
  });
}

class RightsAdvisor {
  final WarrantyService _warranty = WarrantyService();

  bool _has(String text, List<String> keywords) =>
      keywords.any((k) => text.toLowerCase().contains(k));

  bool _vendorRefuses(String response) {
    final words = ['pagare', 'paga tu', 'non è in garanzia', 'non é in garanzia',
        'non coperto', 'non ce ne occupiamo', 'rifiuta', 'rifiutato',
        'non è nostro compito', 'fuori garanzia', 'scaduta'];
    return _has(response, words);
  }

  LegalAdvice analyze(
    Product product,
    String description,
    String vendorResponse,
  ) {
    final fmt = DateFormat('dd/MM/yyyy');
    final months = _warranty.monthsSincePurchase(product.purchaseDate);
    final legalEnd = _warranty.legalEnd(product);

    final warranties = <String>[];
    final documents = <String>[];
    final requests = <String>[];
    final steps = <String>[];

    String summary;
    ClaimRequest inferredRequest = ClaimRequest.riparazione;

    if (_has(description, ['perde acqua', 'perdita', 'filtra', 'gocciola'])) {
      inferredRequest = ClaimRequest.riparazione;
    } else if (_has(description, ['rotto', 'non si accende', 'non funziona',
        'morto', 'bloccato', 'guasto', 'non parte', 'schermo nero', 'crack'])) {
      inferredRequest = ClaimRequest.riparazione;
    } else if (_has(description, ['diverso da', 'non corrisponde',
        'non è quello che', 'senza accessori', 'usato', 'apri la confezione'])) {
      inferredRequest = ClaimRequest.riparazione;
    }

    if (months <= WarrantyService.legalMonths) {
      summary = 'Sulla base delle informazioni generali inserite, risulterebbe potenzialmente applicabile la garanzia legale di conformità (sono trascorsi $months mesi su 24 dall\u2019acquisto). '
          'Il periodo di responsabilità del venditore termina indicativamente il ${fmt.format(legalEnd)}.\n\n'
          '${months <= 12 ? 'Nota sull\u2019onere della prova: poiché il difetto è emerso entro il primo anno, opera la presunzione di difetto preesistente alla consegna, salvo prova contraria del venditore (art. 132 Codice del Consumo).' : 'Nota sull\u2019onere della prova: poiché il difetto è emerso dopo i primi 12 mesi, potrebbe spettare al consumatore dimostrare che la non conformità esisteva già al momento della consegna.'}';

      warranties.add('Garanzia legale di conformità (responsabile: il Venditore) – potenzialmente attiva fino al '
          '${fmt.format(legalEnd)}: copre i difetti di conformità ex artt. 128 e ss. D.Lgs. 206/2005.');

      if (product.commercialWarrantyMonths != null &&
          product.commercialWarrantyMonths! > 0) {
        warranties.add('Garanzia commerciale (responsabile: il Produttore/Garante) – '
            '${product.commercialWarrantyMonths} mesi da ${fmt.format(product.purchaseDate)}'
            '${product.commercialWarrantyProvider != null ? ' emessa da ${product.commercialWarrantyProvider}' : ''}: garanzia autonoma e volontaria, integrativa rispetto alla garanzia legale.');
      }
      if (product.extensionWarrantyMonths != null &&
          product.extensionWarrantyMonths! > 0) {
        warranties.add('Estensione convenzionale di garanzia – '
            '${product.extensionWarrantyMonths} mesi: regolata esclusivamente dalle specifiche condizioni contrattuali pattuite.');
      }

      documents.add('Scontrino, fattura o prova d\u2019acquisto idonea (per verificare data e soggetto venditore).');
      documents.add('Documentazione chiara del difetto (foto, video o descrizione scritta).');
      documents.add('Eventuali riscontri o ricevute di precedenti interventi tecnici.');

      requests.add('Riparazione o sostituzione del bene (rimedi primari alternativi, purché non eccessivamente onerosi o impossibili, art. 135-bis Codice del Consumo).');
      requests.add('In subordine (se i rimedi primari falliscono o sono impossibili): congrua riduzione del prezzo o risoluzione del contratto con rimborso (art. 135-bis).');

      steps.add('Contattare formalmente il venditore (tramite PEC, raccomandata A/R o canali tracciabili) descrivendo dettagliatamente il difetto riscontrato.');
      steps.add('Richiedere il ripristino della conformità senza spese a carico del consumatore.');
      steps.add('In caso di rifiuto ingiustificato o mancata risposta entro un termine congruo (es. 15 giorni), valutare la consultazione di un esperto, un\u2019associazione di consumatori o l\u2019attivazione di procedure di risoluzione alternativa delle controversie (ADR/CAC).');

      if (_vendorRefuses(vendorResponse)) {
        summary += '\n\nAttenzione: la risposta del venditore («${vendorResponse.trim()}») potrebbe configurare un rifiuto di copertura. Si consiglia di conservare ogni comunicazione scritta quale elemento utile a documentare lo stato della controversia.';
      }
    } else {
      final commercial = product.commercialWarrantyMonths != null &&
          product.commercialWarrantyMonths! > months;
      summary = 'La garanzia legale di conformità (24 mesi) risulterebbe scaduta rispetto alla data di acquisto indicata (${fmt.format(product.purchaseDate)}).'
          '${commercial ? ' Potrebbe tuttavia risultare operativa la garanzia commerciale offerta dal produttore.' : ' Non emergono garanzie legali ordinarie attive: gli interventi di riparazione potrebbero essere a carico dell\u2019utente.'}';

      warranties.add('Garanzia legale di conformità (Venditore) – indicativamente scaduta il ${fmt.format(legalEnd)}.');
      if (product.commercialWarrantyMonths != null && product.commercialWarrantyMonths! > 0) {
        warranties.add('Garanzia commerciale (Produttore) – ${product.commercialWarrantyMonths} mesi, '
            '${commercial ? 'potenzialmente ancora attiva.' : 'anch\u2019essa scaduta.'}');
      }

      if (commercial) {
        documents.add('Certificato di garanzia commerciale e prova d\u2019acquisto.');
        documents.add('Evidenze del difetto manifestatosi.');
        requests.add('Richiesta di intervento o riparazione secondo le modalità stabilite nel testo della garanzia commerciale del produttore.');
        steps.add('Contattare il produttore o il centro assistenza autorizzato indicato nelle condizioni di garanzia commerciale.');
      } else {
        documents.add('Documento d\u2019acquisto (utile per valutare profili eccezionali di vizi occulti).');
        requests.add('Verifica di eventuali tutele contrattuali straordinarie o vizi occulti ai sensi dell\u2019art. 1495 c.c. (soggetto a stringenti termini di decadenza e prescrizione).');
        steps.add('Verificare l\u2019eventuale stipula di polizze assicurative o estensioni di garanzia accessorie al momento dell\u2019acquisto.');
        steps.add('In assenza di coperture operative, richiedere un preventivo di riparazione a un centro tecnico specializzato.');
      }
    }

    final draftDraft = ClaimDraft(
      seller: product.seller,
      request: inferredRequest,
      whatHappened: description.trim().isEmpty
          ? 'Il prodotto presenta un difetto di conformità.'
          : description.trim(),
      defectOccurredAt: DateTime.now(),
    );
    final draft = ClaimGenerator().generate(product, draftDraft);

    return LegalAdvice(
      summary: summary,
      warranties: warranties,
      documentsNeeded: documents,
      possibleRequests: requests,
      nextSteps: steps,
      draftCommunication: _shortDraft(draft),
      engineVersion: 'IT-2026.09',
      lastUpdated: '18/09/2026',
      normativeSources: const [
        'D.Lgs. 206/2005 (Codice del Consumo)',
        'D.Lgs. 170/2021 (Attuazione Direttiva UE 2019/771)',
        'Direttiva UE 2019/771 della tutela dei consumatori'
      ],
    );
  }

  String _shortDraft(String full) {
    final lines = full.split('\n');
    final relevant = <String>[];
    for (final line in lines) {
      if (line.trim().isNotEmpty && !line.startsWith('Nome e cognome')) {
        relevant.add(line);
      }
      if (relevant.length >= 24) break;
    }
    return relevant.join('\n');
  }
}