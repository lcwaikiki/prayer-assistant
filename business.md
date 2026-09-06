# Prayer Assist — Business Overview

A plain-language summary of the **Prayer Assist** app for stakeholders,
marketing, product, and business audiences. No engineering knowledge required.
Facts are derived from the current product (September 2026).

---

## 1. What the product is

**Prayer Assist** is a mobile app that supports the daily Islamic practice of
its users in one place. Instead of juggling several apps (a prayer-times app, a
Hijri calendar, a dhikr counter, a fasting tracker, a supplications book), a
user gets a single, free, offline-first companion that covers:

- **Prayer times** — accurate, location-specific times for the six daily
  prayer periods, with live countdowns and reminders.
- **Qibla direction** — a compass that points toward Mecca.
- **Hijri calendar** — the Islamic calendar alongside the Gregorian one,
  including Islamic holidays, moon phases, and fasting days.
- **Dhikr (tesbih) counter** — digital prayer beads with counting, groups,
  and progress statistics.
- **Prayer tracking** — a personal log of completed/missed prayers with
  streaks and monthly statistics.
- **Kaza (Qadaa) tracker** — helps users keep track of missed prayers they
  intend to make up.
- **Fasting assistant** — Ramadan and Sunnah fasts: Iftar/Suhoor countdowns,
  fasting day reminders (Mondays/Thursdays, White Days), and a fasting log.
- **Daily wisdom & supplications** — a rotating verse/hadith of the day and a
  Hisn al-Muslim collection of daily supplications with counters.

**Current version:** 1.0.0. **Platforms:** Android (full experience) and iOS
(core experience).

---

## 2. Who it serves and why it matters

The app targets practicing Muslims worldwide — estimated **~2 billion people**
globally — and in particular:

- Users who want reliable, local prayer times without ads or constant
  connectivity.
- Users who want one app instead of five for daily practice.
- Users who value **privacy and offline usability**: all data stays on the
  device; no account, no cloud, no tracking.
- Users across **12 languages**, with a deliberate focus on Turkey (the
  prayer-times data source is Diyanet-style) and broad reach across the
  Middle East, South Asia, Southeast Asia, and Western diaspora communities.

**Core user value:**

| User need | How Prayer Assist answers it |
|---|---|
| "What time is the next prayer?" | At-a-glance countdown on the home screen and on Android home-screen widgets |
| "Don't let me miss prayers" | Per-prayer reminders, adhan (call-to-prayer) audio option, status-bar countdown |
| "What's today in the Islamic calendar?" | Hijri calendar with holidays, moon phase, secondary Gregorian date |
| "Stay consistent" | Prayer tracking, streaks, monthly heatmap, Kaza debt tracker |
| "Fast correctly" | Iftar/Suhoor countdowns, Sunnah fast-day detection, fasting log |
| "Keep my dhikr routine" | Tesbih counters with reminders and statistics |
| "Travel / weak network?" | Full year of prayer data cached offline after first sync |

---

## 3. Feature summary (business view)

### Prayer times & reminders
Six prayer times per day for the user's location (GPS auto-detect or manual
pick by country → city → district). Live countdown to the next prayer.
Reminders can fire at prayer time, before, or after — each prayer can have its
own vibration/sound settings, including the adhan as the alert sound.

### Home-screen widgets (Android)
Eight widget types — Next Prayer, Remaining Time (including a 1×1 circular
countdown), Daily Prayer Times, Upcoming Reminders, Fasting Countdown,
Calendar, and Moon Phase. These turn the phone's home screen into a permanent,
glanceable prayer dashboard.

### Calendar & reminders
A monthly calendar in either Hijri or Gregorian view (both dates shown on each
day). Islamic holidays (10 major dates), moon phase, and fasting days are
highlighted. Users can create reminders anchored to a calendar date **or** to a
prayer time, with flexible repetition (once, daily, weekly, monthly, yearly —
including true Hijri anniversaries, which shift earlier in the Gregorian
calendar every year).

### Beads (tesbih) module
Digital dhikr counters with haptic feedback, organized into groups, with
reminders and daily/7-day/all-time activity statistics.

### Consistency tools
A personal prayer log (tap a prayer to mark it complete), streak counters,
a monthly completion heatmap, and a dedicated Kaza tracker that estimates when
accumulated missed prayers will be caught up.

### Fasting
Countdowns to Iftar and Suhoor, automatic detection of recommended Sunnah fast
days (Monday/Thursday, the 13th–15th of each Hijri month, Ashura, Arafah),
notifications for those days, and a yearly fasting log.

### Content & wisdom
A daily rotating Quranic verse or hadith with translation and transliteration,
shareable with others, plus a searchable library of essential supplications
(Hisn al-Muslim) with built-in counters.

### Data portability
Complete backup/restore in one JSON file, plus export of Islamic holidays to
standard calendar (.ics) format so they appear in Google Calendar or Apple
Calendar.

---

## 4. Market & positioning

**Category:** Lifestyle / Religion / Productivity. Comparable products include
generic prayer-time apps (e.g., Diyanet's own app in Turkey) and all-in-one
Islamic lifestyle apps (e.g., Muslim Pro, Pillars, Athan). Differentiators:

1. **No account, no ads, no data collection** — a trust advantage in a
   category where privacy concerns are growing.
2. **True offline operation** after first sync.
3. **Breadth** — prayer times, calendar, Qibla, dhikr, fasting, tracking, and
   supplications in one app, unlike focused single-purpose apps.
4. **Android-first depth** — 8 home-screen widgets is more than most
   competitors offer.
5. **12 languages**, including Turkish and full Hijri/calendar localization
   with native Arabic month names.

**Target launch region:** Turkey first (data source and translations are most
complete there), then broader markets via the store listings already drafted
(`features.md`).

---

## 5. Current status & readiness

**What's done:** All major feature modules are implemented and tested
(unit, widget, golden, and integration smoke tests; static analysis is clean
of errors). The app is at version 1.0.0 and builds to a release APK.

**What remains before a store launch:**

| Item | Effort |
|---|---|
| Replace placeholder app description in build metadata | Small |
| Change Android package identifier to a proper reverse-domain name | Small (one-time, before release) |
| Verify notification deep-links on a physical device | Small (manual QA) |
| App-store screenshots + feature graphic | Medium |
| Finalize store listing copy (draft exists in `features.md`) | Small |
| Decide on iOS feature parity for launch (widgets/countdown are Android-only today) | Product decision |

**Risks & dependencies:**

- Prayer times depend on a third-party Diyanet-style API
  (`ezanvakti.imsakiyem.com`); if it becomes unavailable, existing users keep
  their cached year but new locations can't be added. A long-term alternative
  or self-hosted mirror is worth evaluating.
- Location coverage is limited to the regions served by that API.
- iOS lacks the home-screen widgets and status-bar countdown; marketing copy
  must not overpromise.

---

## 6. Growth & monetization options (not yet implemented)

The app is currently free with no monetization. Natural future options, in
roughly increasing aggressiveness:

1. **Keep it free** — differentiate on privacy and use it as a portfolio /
   goodwill product.
2. **Donation / "support the developer"** — common and well-received in this
   category.
3. **Premium tier** (subscription or one-time): extra content (larger
   supplications library, more wisdom content), unlimited custom locations,
   additional widget themes, iOS widgets.
4. **Paid content packs** — e.g., localized surah/hadith collections.
5. **Affiliate/ad-based only if unavoidable** — the privacy stance is a
   competitive asset; ads would erode it.

---

## 7. Suggested roadmap (business priorities)

**Near term (launch):** housekeeping items above, iOS parity pass for core
features, store assets, and a small beta (e.g., Turkey + diaspora communities)
to collect ratings and fix real-device issues.

**Medium term (growth):**
- More prayer-time data sources for worldwide coverage (currently
  Diyanet-style locations).
- Widget parity on iOS (via iOS WidgetKit).
- Cloud backup option (opt-in) for users who change devices — today backup is
  manual file export/import.
- Analytics dashboard for monthly habit reports (exportable).

**Long term (moat):**
- Community features done privacy-first (e.g., local mosque prayer-time
  corrections, community-curated supplications).
- Wear OS / Apple Watch companion for at-a-glance prayer times and countdown.
- Fully offline astronomical prayer-time calculation engine, removing the
  third-party API dependency entirely.

---

## 8. One-page summary

> **Prayer Assist** is a free, offline-first, privacy-respecting mobile app
> that covers the full circle of daily Islamic practice: prayer times and
> reminders (with adhan audio), Qibla compass, Hijri/Gregorian calendar with
> holidays and moon phases, dhikr counters, prayer tracking with streaks,
> missed-prayer (Kaza) tracking, a fasting assistant, daily wisdom, and a
> supplications library — in 12 languages, with 8 Android home-screen widgets.
> Version 1.0.0 is feature-complete and tested; the remaining work before a
> store launch is packaging polish (metadata, store assets, final device QA),
> with clear, low-risk growth paths afterward.