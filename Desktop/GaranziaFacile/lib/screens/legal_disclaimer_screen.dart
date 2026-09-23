import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gf/gf_buttons.dart';
import '../widgets/gf/gf_foundation.dart';

class LegalDisclaimerScreen extends StatefulWidget {
  const LegalDisclaimerScreen({super.key});

  @override
  State<LegalDisclaimerScreen> createState() => _LegalDisclaimerScreenState();
}

class _LegalDisclaimerScreenState extends State<LegalDisclaimerScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GFContent(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.outline),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'INTRODUZIONE REQUISITI',
                        style: TextStyle(
                          color: AppColors.primaryDeep,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Informazioni legali e condizioni di utilizzo',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Leggi attentamente prima di iniziare a usare l\u2019applicazione.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _paragraph(
                      'GaranziaFacile è uno strumento digitale destinato ad aiutare l\u2019utente nella gestione dei propri acquisti, documenti, garanzie e comunicazioni con venditori, produttori e altri soggetti.',
                    ),
                    _paragraph(
                      'Le informazioni, analisi, suggerimenti, classificazioni e bozze generate dall\u2019app sono elaborate automaticamente sulla base dei dati e delle informazioni inserite dall\u2019utente e hanno esclusivamente finalità informative e di supporto.',
                    ),
                    const Divider(height: 24),
                    _sectionTitle('GaranziaFacile non fornisce consulenza legale'),
                    _paragraph(
                      'Le informazioni fornite da GaranziaFacile non costituiscono parere legale, consulenza legale, attività di rappresentanza, assistenza stragiudiziale o giudiziale, né instaurano alcun rapporto professionale tra l\u2019utente e GaranziaFacile o i suoi gestori.',
                    ),
                    _paragraph(
                      'L\u2019app non sostituisce la valutazione di un avvocato o di altro professionista qualificato.',
                    ),
                    _sectionTitle('Risultati automatizzati'),
                    _paragraph(
                      'Le indicazioni relative alla possibile applicazione di una garanzia, ai diritti del consumatore, ai soggetti da contattare, ai documenti necessari, ai termini e ai possibili rimedi sono generate automaticamente e possono non tenere conto di tutte le circostanze giuridiche e fattuali del caso concreto.',
                    ),
                    _paragraph(
                      'Un risultato indicato dall\u2019app come "applicabile", "potenzialmente applicabile", "non applicabile", "in scadenza" o con altra classificazione non costituisce una determinazione definitiva della posizione giuridica dell\u2019utente.',
                    ),
                    _paragraph(
                      'L\u2019utente è responsabile della verifica della correttezza dei dati inseriti e delle informazioni utilizzate dall\u2019app.',
                    ),
                    _sectionTitle('Bozze di comunicazioni'),
                    _paragraph(
                      'Le lettere, i reclami, le richieste e gli altri documenti generati da GaranziaFacile sono bozze predisposte automaticamente sulla base delle informazioni fornite dall\u2019utente.',
                    ),
                    _paragraph(
                      'Prima dell\u2019invio, l\u2019utente deve verificarne il contenuto, i dati personali, il destinatario, le date, gli importi, la descrizione del problema e ogni altra informazione rilevante.',
                    ),
                    _paragraph(
                      'La generazione di una comunicazione non garantisce che la richiesta sia fondata, accoglibile o idonea a produrre uno specifico risultato.',
                    ),
                    _sectionTitle('Normativa'),
                    _paragraph(
                      'I riferimenti normativi eventualmente mostrati dall\u2019app sono forniti a fini informativi e possono essere soggetti a modifiche, aggiornamenti, interpretazioni giurisprudenziali o applicazioni differenti in relazione al caso concreto.',
                    ),
                    _paragraph(
                      'L\u2019utente deve fare riferimento alla normativa vigente e, quando necessario, rivolgersi a un professionista qualificato.',
                    ),
                    _sectionTitle('Responsabilità dell\u2019utente'),
                    _paragraph(
                      'L\u2019utente è responsabile delle informazioni e dei documenti caricati nell\u2019app e delle decisioni assunte sulla base delle informazioni visualizzate.',
                    ),
                    _paragraph(
                      'GaranziaFacile non deve essere utilizzata come unico elemento sul quale fondare decisioni che possano comportare conseguenze economiche o giuridiche rilevanti.',
                    ),
                    _sectionTitle('Invio delle comunicazioni'),
                    _paragraph(
                      'Quando l\u2019utente decide di inviare una comunicazione generata dall\u2019app, tale invio avviene sulla base della sua scelta e della sua verifica del contenuto.',
                    ),
                    _paragraph(
                      'GaranziaFacile non garantisce che il destinatario riceva, accetti o accolga la comunicazione, né che la comunicazione produca uno specifico risultato.',
                    ),
                    _sectionTitle('Situazioni complesse'),
                    _paragraph(
                      'In presenza di controversie, rifiuti del venditore o del produttore, danni rilevanti, termini contestati, importi significativi, procedimenti giudiziari, diffide, richieste di risarcimento o altre questioni giuridiche complesse, si raccomanda di rivolgersi a un professionista qualificato.',
                    ),
                     _paragraph(
                      'Utilizzando GaranziaFacile, l\'utente dichiara di aver letto e compreso le presenti informazioni e di utilizzare il servizio secondo le finalità sopra indicate.',
                    ),
                    _sectionTitle('Privacy e protezione dei dati'),
                    _paragraph(
                      'GaranziaFacile è un\'app offline 100% locale. Tutti i dati che inserisci (prodotti, scontrini, foto, allegati) vengono elaborati e salvati esclusivamente sul tuo dispositivo e non vengono mai inviati su Internet né al titolare né a terzi. L\'app non utilizza servizi di analytics, pubblicità o backend cloud.',
                    ),
                    _paragraph(
                      'L\'app utilizza Google ML Kit (on-device) per la scansione OCR e barcode: l\'elaborazione avviene localmente, ma tali SDK possono trasmettere dati tecnici/diagnostici a Google. Consulta: developers.google.com/ml-kit/android-data-disclosure',
                    ),
                    _paragraph(
                      'Puoi eliminare definitivamente tutti i dati in qualsiasi momento da Profilo → Impostazioni → Elimina tutti i dati.',
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse('https://purpo-ai.github.io/garanziafacile/privacy-policy.html'),
                        ),
                        icon: const Icon(Icons.open_in_browser, size: 16),
                        label: Text(
                          'Leggi l\'informativa privacy completa',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.outline),
                  ),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _accepted,
                      activeColor: AppColors.primary,
                      title: Text(
                        'Dichiaro di aver letto e compreso le informazioni legali e accetto le condizioni di utilizzo di GaranziaFacile.',
                        style: AppTypography.caption.copyWith(color: AppColors.text, fontSize: 12),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _accepted = val ?? false),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: GFPrimaryButton(
                        label: 'Accetta e Continua',
                        icon: Icons.check_circle_outline,
                        onPressed: _accepted
                            ? () {
                                context.read<AppState>().acceptDisclaimer();
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: AppTypography.heading.copyWith(fontSize: 15, color: AppColors.primaryDeep),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTypography.body.copyWith(fontSize: 13.5, height: 1.45, color: AppColors.textMuted),
      ),
    );
  }
}