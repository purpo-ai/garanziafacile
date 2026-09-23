import 'package:intl/intl.dart';

import '../models/enums.dart';
import '../models/product.dart';

class ClaimDraft {
  final String consumerName;
  final String consumerAddress;
  final String seller;
  final String saleReference;
  final ClaimRequest request;
  final String whatHappened;
  final DateTime? defectOccurredAt;
  final int replyDays;

  const ClaimDraft({
    this.consumerName = '',
    this.consumerAddress = '',
    required this.seller,
    this.saleReference = 'Prova d\'acquisto',
    required this.request,
    required this.whatHappened,
    this.defectOccurredAt,
    this.replyDays = 15,
  });
}

class ClaimGenerator {
  DateTime _now() => DateTime.now();

  String generate(Product product, ClaimDraft draft) {
    final fmt = DateFormat('dd/MM/yyyy');
    final now = _now();
    final buffer = StringBuffer();

    buffer.writeln('Spett.le');
    buffer.writeln(draft.seller.trim().isEmpty ? 'IL VENDITORE' : draft.seller.trim());
    if ((product.sellerAddress?.isNotEmpty ?? false)) {
      buffer.writeln(product.sellerAddress!);
    }
    buffer.writeln();
    buffer.writeln('Oggetto: reclamo per difetto di conformità del prodotto '
        'ex art. 128 e ss. D.Lgs. 6 settembre 2005, n. 206 (Codice del consumo) '
        'e artt. 128-135, come modificati dal D.Lgs. 170/2021');
    buffer.writeln();
    buffer.writeln('Gentile ${draft.seller.trim().isEmpty ? 'venditore' : draft.seller.trim()},');
    buffer.writeln();

    final productLine = [
      product.name,
      if (product.brand.isNotEmpty) 'marca ${product.brand}',
      if (product.model.isNotEmpty) 'modello ${product.model}',
    ].join(', ');

    buffer.writeln('Con la presente intendo formalmente segnalare il difetto di '
        'conformità del seguente prodotto:');
    buffer.writeln();
    buffer.writeln('- Prodotto: $productLine');
    buffer.writeln('- Categoria: ${product.category.label}');
    if (product.serialNumber != null && product.serialNumber!.isNotEmpty) {
      buffer.writeln('- Numero seriale: ${product.serialNumber}');
    }
    buffer.writeln('- Codice a barre: ${product.barcode ?? 'non indicato'}');
    buffer.writeln('- Data di acquisto: ${fmt.format(product.purchaseDate)}');
    if (product.price != null) {
      buffer.writeln('- Prezzo pagato: ${product.price!.toStringAsFixed(2)} €');
    }
    buffer.writeln('- Documento di acquisto: ${draft.saleReference}');
    buffer.writeln();

    final months = (now.year - product.purchaseDate.year) * 12 +
        (now.month - product.purchaseDate.month);
     buffer.writeln('Il prodotto è coperto dalla garanzia legale di conformità '
         '(24 mesi) di cui al Codice del consumo. Il difetto si è manifestato '
         'circa $months mes. dopo l\u2019acquisto:');
     buffer.writeln();
     buffer.writeln(
         'La valutazione di conformità spetta al venditore: il difetto doveva '
         'esistere alla consegna per configurare garanzia legale.');
     buffer.writeln();
    buffer.writeln(draft.whatHappened.trim());
    if (draft.defectOccurredAt != null) {
      buffer.writeln(
          'Il difetto è comparso in data ${fmt.format(draft.defectOccurredAt!)}.');
    }
    buffer.writeln();

    switch (draft.request) {
      case ClaimRequest.riparazione:
        buffer.writeln('Alla luce di quanto sopra, LE RICHIEDO la riparazione '
            'del prodotto ai sensi dell\u2019art. 130 del Codice del consumo, senza '
            'spese a mio carico e entro ${draft.replyDays} giorni dalla ricezione '
            'della presente.');
      case ClaimRequest.sostituzione:
        buffer.writeln('Alla luce di quanto sopra, LE RICHIEDO la sostituzione '
            'del prodotto con uno nuovo e conforme ai sensi dell\u2019art. 130 del '
            'Codice del consumo, entro ${draft.replyDays} giorni dalla ricezione '
            'della presente.');
      case ClaimRequest.riduzionePrezzo:
        buffer.writeln('Alla luce di quanto sopra, LE RICHIEDO una proporzionale '
            'riduzione del prezzo ai sensi dell\u2019art. 130 del Codice del consumo, '
            'qualora la riparazione o la sostituzione non possano essere eseguite.');
      case ClaimRequest.risoluzione:
        buffer.writeln('Alla luce di quanto sopra, LE RICHIEDO la risoluzione '
            'del contratto con integrale rimborso del prezzo versato, ai sensi '
            'dell\u2019art. 130 del Codice del consumo, in quanto il difetto è di '
            'rilevanza tale da rendere il prodotto non utilizzabile.');
    }
    buffer.writeln();
    buffer.writeln('Evidenzio inoltre che, ai sensi dell\u2019art. 132 del Codice '
        'del consumo, spetta al venditore dimostrare che il difetto non '
        'sussisteva al momento della consegna.');
    buffer.writeln();
    buffer.writeln('Resto in attesa di un Suo cortese riscontro entro e non oltre '
        '${draft.replyDays} giorni dalla ricezione della presente. In mancanza di '
        'riscontro o di soluzione, mi riservo di adire le competenti autorità, '
        'anche tramite le Associazioni dei consumatori o la procedura di '
        'risoluzione alternativa delle controversie (ADR/CAC).');
    buffer.writeln();
    buffer.writeln('Distinti saluti.');
    buffer.writeln();
    if (draft.consumerName.trim().isNotEmpty) {
      buffer.writeln(draft.consumerName.trim());
      if (draft.consumerAddress.trim().isNotEmpty) {
        buffer.writeln(draft.consumerAddress.trim());
      }
    } else {
      buffer.writeln('Nome e cognome');
    }

    return buffer.toString();
  }

  String emailSubject(Product product, ClaimDraft draft) {
    final fmt = DateFormat('dd/MM/yyyy');
    return 'Reclamo garanzia ${product.name} del ${fmt.format(product.purchaseDate)} '
        '- ${draft.request.label}';
  }
}