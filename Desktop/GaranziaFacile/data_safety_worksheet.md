# Google Play Data Safety — Worksheet GaranziaFacile

> **Versione app:** 1.0.0+1  
> **Data di verifica:** 18 settembre 2026  
> **Compilatore:** GaranziaFacile — progetto open source (Milano, Italia)  
> **Audit SDK completato:** ✅

---

## 🔍 Metodologia

Questo worksheet è basato su:
1. **Audit del codice Dart:** verificato che non esistano chiamate HTTP, rete o API esterne
2. **Audit native Android:** verificati `build.gradle.kts` di tutti i plugin Flutter
3. **Verifica manifest:** confermato che `android.permission.INTERNET` **non** è nel manifest `main` (solo debug/profile)
4. **Documentazione SDK:** [ML Kit Android Data Disclosure](https://developers.google.com/ml-kit/android-data-disclosure)

---

## 1. Dati raccolti (Collected)

### 1.1 Dati utente — contenuti elaborati localmente

| Tipo di dato | Raccolto? | Motivazione |
|---|---|---|
| Nome prodotto | **NO** | Salvato localmente nel JSON del dispositivo |
| Marca / modello | **NO** | Salvato localmente nel JSON |
| Prezzo / data acquisto | **NO** | Salvato localmente nel JSON |
| Numero seriale / barcode | **NO** | Salvato localmente nel JSON |
| Foto ricevute / documenti | **NO** | Processati in memoria, opzionalmente salvati localmente |
| Testo OCR estratto | **NO** | Processato localmente da ML Kit on-device |
| Bozze di reclami | **NO** | Salvate localmente nel JSON |
| Allegati (PDF, immagini) | **NO** | Salvati nella cartella `attachments/` locale |

> **Google Play definisce "collected" come trasmissione fuori dal dispositivo.**  
> Fonte: [Google Play - Understand data collection](https://support.google.com/googleplay/android-developer/answer/10787469)  
> **Conclusione:** nessun dato utente viene raccolto — rimane sul dispositivo.

### 1.2 Dati tecnici da SDK di terze parti

| SDK | Versione | Dati tecnici trasmessi | Da dichiarare? |
|---|---|---|---|
| `com.google.mlkit:text-recognition` | 16.0.1 | device info, app info, install ID, performance metrics, API config, input/output sizes, error diagnostics | **SÌ** (vedi nota) |
| `com.google.mlkit:barcode-scanning` | 17.3.0 | stessi tipi di dati tecnici di ML Kit | **SÌ** (vedi nota) |
| `mobile_scanner` (AndroidX Camera) | - | NO — usa solo camera hardware, AndroidX CameraX | NO |
| `image_picker` (Photo Picker) | - | NO — sistema Android gestisce la selezione | NO |
| `file_picker` | - | NO — sistema Android gestisce la selezione | NO |
| `flutter_local_notifications` | - | NO — notifiche locali | NO |
| `share_plus` | - | NO — solo Android Intent del sistema | NO |
| `path_provider` | - | NO — accesso interno al filesystem | NO |

> **Nota ML Kit:** Google dichiara che ML Kit on-device non invia i contenuti delle immagini/testo processati. Tuttavia, l'SDK raccoglie dati tecnici/diagnostici (device/app info, metriche performance, identificatori installazione, eventi) per "migliorare ML Kit, debuggare problemi e garantire compatibilità".  
> Fonte: [ML Kit Android Data Disclosure](https://developers.google.com/mlkit/android-data-disclosure)  
> **Azioni per Data Safety:**
> - Dichiarare la raccolta di dati tecnici diagnostici
> - Specificare che NON riguardano i contenuti utente
> - Inserire il link all'informativa: `https://developers.google.com/ml-kit/android-data-disclosure`

---

## 2. Dati condivisi (Shared)

| Destinatario | Tipo di dato | Condiviso? | Motivazione |
|---|---|---|---|
| Google (ML Kit) | Dati tecnici/diagnostici | **SÌ** (SDK di terza parti) | Google ML Kit raccoglie dati tecnici come dichiarato nella documentazione |
| Terze parti (email, social) | Contenuti utente (PDF, allegati) | **NO** (dall'app) | Condivisione avviene solo tramite intent OS su azione esplicita utente (`share_plus`) |
| Backend/Server del titolare | Qualsiasi dato | **NO** | Nessun backend esiste |
| Analytics / pubblicità | Qualsiasi dato | **NO** | Nessun SDK analytics presente |

> **Google Play Data Safety:** Google dice che i dati trasmessi tramite share iniziati dall'utente (come inviare un documento via email) **non** devono essere dichiarati come "shared" se l'utente li ha espressamente scelti.  
> Fonte: [Google Play - Data shared in response to user action](https://support.google.com/googleplay/android-developer/answer/10787469#zippy=%2Cdata-shared%2Cdata-collected)  
> **Conclusione:** la condivisione tramite `share_plus` **NON** deve dichiararsi come "shared".

---

## 3. Sicurezza (Security practices)

| Pratica | Implementata? | Note |
|---|---|---|
| Crittografia dati in transito | **Non applicabile** | Nessun dato in transito |
| Crittografia dati a riposo | **NO** | File JSON locale non cifrato (nota nella policy) |
| Richiesta autenticazione | **NO** | Nessun account/password |
| **Richiesta autenticazione** per dati sensibili | **NO** | Nessun account online |

> **Nota:** La mancanza di crittografia a riposo è accettabile per un'app locale offline, ma va dichiarata onesta in Data Safety.

---

## 4. Account utente (User accounts)

| Campo | Valore |
|---|---|
| L'app offre account utente? | **NO** |
| L'app permette di creare account? | **NO** |
| L'app richiede login? | **NO** |
| Cancellazione account richiesta da Google Play? | **NO** — non serve una procedura dedicata a "cancellazione account" |

---

## 4. Permessi Android

| Permesso | Richiesto? | Finalità | Dati trasmessi |
|---|---|---|---|
| `CAMERA` | SÌ | Scansione barcode, acquisizione immagini | NO — elaborazione locale |
| `POST_NOTIFICATIONS` | SÌ (Android 13+/API 33+) | Promemoria scadenze garanzia (notifiche locali) | NO — nessun dato inviato |
| `INTERNET` | NO (solo debug/profile) | Sviluppo | N/A — non presente in release |

### Note su POST_NOTIFICATIONS

- Android 13+ richiede `POST_NOTIFICATIONS` per tutte le notifiche, inclusse locali
- L'app lo richiede a runtime tramite `flutter_local_notifications`
- Nessun dato personale viene trasmesso tramite le notifiche

---

## 5. Compilazione Data Safety — schema di risposta

Questo è ciò che andrà compilato nella **Play Console → Data Safety**:

### Dati raccolti
1. **Dati tecnici/diagnostici (da ML Kit)** → **SÌ**, categoria "Diagnostics"
   - Device info, app info, install ID, performance metrics
   - Finalità: monitoraggio performance, debugging, compatibilità
   - Link SDK: `https://developers.google.com/ml-kit/android-data-disclosure`

2. **Tutti i dati utente (prodotti, foto, OCR, ecc.)** → **NO** raccolti

### Dati condivisi
1. **ML Kit → Google** → **SÌ** (solo dati tecnici, non contenuti utente)
2. **share_plus** → **NO** (azione utente esplicita, esente da dichiarazione)

### Sicurezza
1. Crittografia a riposo → **NO**
2. Autenticazione → **NO** (nessun account)

### Account
1. Account utente → **NO**
2. Gestione cancellazione account → **NON APPLICABILE** (nessun account)

---

## 6. Prossimi step

1. ✅ Privacy Policy pubblicata → inserire URL in console → ✅ Data Safety compilata
2. 📱 Test AAB su dispositivo reale
3. 📱 Play Console → Internal Testing
4. 🛡️ Verifica Google Play Policy Scan (assicurarsi che IMEI non comparra)

---

*Creato da audit codice — 18 settembre 2026*
