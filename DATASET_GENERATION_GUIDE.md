# Islamic Dataset Generation & Localization Guide

This guide documents the end-to-end methodology used to source, structure, translate, sanitize, and validate the 600 authentic Ahl al-Sunnah entries across `assets/data/daily_wisdom.json` (300 items) and `assets/data/supplications.json` (300 items) in all 14 supported application languages.

---

## 1. Requirements & Core Principles

- **Authenticity (Ahl al-Sunnah)**: Zero fabricated or AI-generated texts. All content is derived strictly from primary Quranic Uthmani text, *Sahih al-Bukhari*, and *Hisn al-Muslim* (Fortress of the Muslim by Shaykh Sa'id bin Ali bin Wahf al-Qahtani).
- **Target Scale**: Exactly 300 unique entries per JSON file (total 600 entries, 0 duplicates).
- **Universal Multi-Language Coverage**: 14 supported locales without empty strings or null fallbacks:
  `en`, `tr`, `ar`, `ur`, `fa`, `de`, `es`, `fr`, `id`, `ru`, `ja`, `zh`, `bn`, `ta`.
- **Clean Transliteration & Metadata**: Tashkeel on Arabic text, standard Latin transliteration without broken Unicode symbols, exact repeat counts (`target_count`), and authoritative citations.

---

## 2. Trusted Data Sources

### A. Quranic Verses (150 Ayahs for Daily Wisdom)
Sourced via verified editions from `fawazahmed0/quran-api`:
- **Arabic**: `ara-quranacademy` (Official Uthmani text)
- **English**: `eng-abdelhaleem` (M.A.S. Abdel Haleem, Oxford World's Classics)
- **Turkish**: `tur-diyanetisleri` (Diyanet İşleri Başkanlığı)
- **Urdu**: `urd-abulaalamaududi` (Abul A'la Maududi)
- **Persian**: `fas-hussainansarian` (Hussain Ansarian)
- **German**: `deu-aburidamuhammad` (Abu Rida Muhammad ibn Ahmad ibn Rassoul)
- **Spanish**: `spa-muhammadisagarc` (Muhammad Isa Garcia)
- **French**: `fra-muhammadhamidul` (Muhammad Hamidullah)
- **Indonesian**: `ind-indonesianislam` (Indonesian Islamic Affairs Ministry)
- **Russian**: `rus-ministryofawqaf` (Ministry of Awqaf, Russian Federation)
- **Japanese**: `jpn-ryoichimita` (Ryoichi Mita, Japan Muslim Association)
- **Chinese**: `zho-majian` (Muhammad Ma Jian)
- **Bengali**: `ben-muhiuddinkhan` (Muhiuddin Khan)
- **Tamil**: `tam-abdulhameedbaqa` (Janab Abdul Hameed Baqavi)

### B. Hadith (150 Hadiths for Daily Wisdom)
Sourced from *Sahih al-Bukhari* via authentic editions in `fawazahmed0/hadith-api`:
- Direct primary editions for 9 languages: `ara`, `eng`, `tur`, `urd`, `ben`, `ind`, `fra`, `rus`, `tam`.
- Filtered for concise, profound moral and spiritual sayings (iman, prayer, charity, character, brotherhood, patience).
- Remaining 5 languages (`de`, `es`, `fa`, `ja`, `zh`) translated from verified English text using batch translation pipelines.

### C. Supplications (300 Adhkar for Supplications)
Sourced directly from *Hisn al-Muslim* (Fortress of the Muslim):
- 268 base supplications paired 1-to-1 with English translations, transliterations, and Hadith citations.
- 32 additional authentic supplications from *Hisn al-Muslim* chapters on Tasbih, Tahmid, Istighfar, and Salawat.
- Categorized into the application's 5 domain categories:
  - `morning` (20 items)
  - `evening` (13 items)
  - `sleeping` (18 items)
  - `after_prayer` (73 items)
  - `daily_life` (176 items)

---

## 3. High-Performance Batch Translation Pipeline

When translating remaining languages from verified texts:
1. **Avoiding Rate Limits (HTTP 429)**: Calling endpoints with unthrottled single-string requests triggers rate limits. Using `client=dict-chrome-ex` combined with batching provides stability.
2. **Separator-Based Batching**: Joining 8–10 supplications with a distinctive delimiter (e.g., `\n###\n`) allows translating up to 10 entries in a single HTTP request while preserving sentence alignment:
   ```python
   combined = '\n###\n'.join(batch_texts)
   url = f'https://translate.googleapis.com/translate_a/single?client=dict-chrome-ex&sl=en&tl={target_lang}&dt=t&q=' + urllib.parse.quote(combined)
   # Splitting by '###' restores exact individual translations
   ```
3. **Persistent Local Caching**: Storing results in JSON caches ensures idempotent execution and zero duplicate network calls.

---

## 4. Sanitation & Quality Filtering

### A. Transliteration Sanitation
Raw Arabic text containing Quranic recitation glyphs and waqf marks produces garbled Latin characters if transliterated naively. The cleaning pipeline:
- Strips Quranic recitation/pause marks (`\u06D6` through `\u06ED`).
- Normalizes Alif Waslah (`\u0671` -> `a`), Superscript Alif (`\u0670` -> `a`), and Farsi Yeh (`\u06CC` -> `y`).
- Removes tatweel (`\u0640`) and Quranic ornamentation.
- Ensures all transliterations output clean Latin typography (`A-Z`, `a-z`, `'`, `-`, spaces).

### B. Hadith Isnad Trimming
Raw Hadith databases often prepend full chains of transmission (e.g., in Indonesian: *"Telah menceritakan kepada kami Musaddad berkata, telah menceritakan kepada kami Yahya dari Syu'bah..."*). 
- Automated regex trimming extracts the primary narrator and the prophetic saying (*matn*), matching the concise display format of English and Turkish cards.

---

## 5. Schema & Integration Verification

Both datasets conform to `lib/src/supplications/models/supplication_models.dart`:

### `daily_wisdom.json` Schema:
```json
{
  "id": "wisdom_hadith_1",
  "type": "hadith", // "ayah" or "hadith"
  "reference": "Sahih al-Bukhari #1",
  "text_ar": "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ...",
  "transliteration": "Innama al'a'maalu bialniyyaati...",
  "translations": {
    "en": "...", "tr": "...", "ar": "...", "ur": "...", "fa": "...",
    "de": "...", "es": "...", "fr": "...", "id": "...", "ru": "...",
    "ja": "...", "zh": "...", "bn": "...", "ta": "..."
  }
}
```

### `supplications.json` Schema:
```json
{
  "id": "supp_morning_1",
  "category": "morning", // "morning" | "evening" | "after_prayer" | "sleeping" | "daily_life"
  "reference": "Hisn al-Muslim 1",
  "target_count": 1,
  "text_ar": "الحَمْـدُ لِلّهِ الّذي أَحْـيانا...",
  "transliteration": "Alhamdu lillahil-ladhi ahyana...",
  "translations": { ... 14 languages ... }
}
```

---

## 6. Testing & Quality Checks

Run the verification suite after any dataset modifications:

```bash
# 1. Verify item counts, schema integrity, and non-empty translations across 14 languages
flutter test test/unit/l10n/tamil_bengali_localizations_test.dart

# 2. Verify all unit tests
flutter test test/unit/

# 3. Verify daily wisdom card rendering
flutter test test/widget/daily_wisdom_card_test.dart

# 4. Check localization code generation
flutter gen-l10n
```
