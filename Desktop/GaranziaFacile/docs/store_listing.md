# Google Play Store — Store Listing & Release Prep

## Store Listing

| Campo | Valore |
|---|---|
| **Titolo** | GaranziaFacile — Gestione Garanzie e Reclami |
| **Short description** | Gestisci le garanzie, reclami e documenti dei tuoi acquisti. 100% offline, zero tracciamento. |
| **Full description** | GaranziaFacile è un'app mobile** 100% offline** per proteggere i tuoi acquisti e gestire le garanzie con tranquillità. |

**🔐 Privacy prima di tutto**
- Nessun dato lascia il tuo dispositivo
- Nessun account, nessun backend, nessuna pubblicità
- Nessun analytics né tracciamento
- Tutto salvato in locale, crittografato dal filesystem Android

**📱 Funzionalità principali**
- Aggiungi prodotti tramite **barcode**, **OCR** (scansione ricevute/etichette) o **manuale**
- Monitora lo stato delle garanzie con **Warranty Ring** animato
- Scopri le **garanzie in scadenza** con promemoria push
- Genera **reclami formalmente corretti** con riferimenti al Codice del Consumo
- **Condividi** bozze PDF, email o salva come bozza
- Gestisci una **timeline** interattiva di ogni prodotto
- **Cancella tutti i dati** in un solo tap

**🧠 Problemi? Ti guidiamo noi**
- Percorso guidato per segnalare difetti
- Analisi del problema con consigli pratici
- Generazione automatica della lettera di reclamo

**✅ Offline-first**
- Funziona senza connessione internet
- Nessun dato mai trasmesso

*GaranziaFacile non fornisce consulenza legale. Le bozze sono generate automaticamente e devono essere verificate prima dell'invio.* |
| **Categoria** | Strumenti (Tools) |
| **Sottocategoria** | Utilità (Productivity) |
| **Tag/Keyword** | garanzia, reclami, offline, privacy, protezione consumatori, codice del consumo, OCR, barcode scanner, fatture |
| **Classificazione età** | 12+ (nessun contenuto sensibile) |
| **Privacy Policy URL** | https://purpo-ai.github.io/garanziafacile/privacy-policy.html |

## Release Notes (v1.0.0)

```
✨ GaranziaFacile 1.0 — ora disponibile!

La tua custodia digitale per acquisti e garanzie:

• Aggiungi prodotti via barcode, OCR o manuale
• Monitora garanzie con l'animato Warranty Ring
• Promemoria scadenze con notifiche locali
• Generatore di reclami basato sul Codice del Consumo
• 100% offline — nessun dato lascia il tuo dispositivo
• Zero pubblicità, zero tracking, zero account

Beta testing completata. Pronta per l'uso.
```

## Data Safety Form — Compilation Guide

1. **Dati raccolti**:
   - Tipo: "Dati tecnici/diagnostici"
   - Fonte: ML Kit (Google)
   - Finalità: "Monitoraggio prestazioni", "Debug", "Compatibilità"
   - Link SDK: https://developers.google.com/ml-kit/android-data-disclosure

2. **Dati condivisi**:
   - Tipo: "Dati tecnici/diagnostici"  
   - Destinatario: "Google"
   - Condiviso: SÌ (via ML Kit SDK)

3. **Sicurezza**:
   - Crittografia a riposo: NO
   - Autenticazione: NO
   - Account utente: NO

4. **Cancellazione account**: NON APPLICABILE (nessun account)

## Store Listing Checklist

| Item | Status |
|---|---|
| High-res icon (512x512 PNG) | ✅ `ic_launcher.png` |
| Feature graphic (1024x500) | ⚠️ Da creare |
| Screenshots (min 2, max 8) | ⚠️ Da generare |
| Promo graphic | ⚠️ Opzionale |
| Video trailer | ⚠️ Opzionale |
| Privacy Policy URL | ✅ Impostato |
| Email contatto sviluppatore | ✅ privacy@garanziafacile.it |
| Categoria | ✅ Strumenti → Utilità |
| Classificazione età | ✅ 12+ |

## Policy Compliance Checklist

| Policy | Status |
|---|---|
| Permissions justified | ✅ CAMERA solo per scanner |
| No SMS/CallLog/etc | ✅ |
| IMEI rimosso | ✅ |
| No Firebase/analytics | ✅ |
| Offline data policy | ✅ |
| Account deletion | ✅ (cancella tutti i dati) |
| Children's privacy | ✅ (non rivolta a <13) |
| Ads/D payments | ✅ Nessuna |
| Data Safety complete | ✅ (vedi worksheet) |
