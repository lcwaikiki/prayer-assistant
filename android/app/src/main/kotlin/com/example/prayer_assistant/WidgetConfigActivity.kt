package com.pirci.prayer_assistant

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.SeekBar
import android.widget.TextView

class WidgetConfigActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    private data class ConfigStrings(
        val title: String,
        val themeHeader: String,
        val themeSystem: String,
        val themeLight: String,
        val themeDark: String,
        val themeTransparent: String,
        val calendarDisplayHeader: String,
        val calendarDisplayBoth: String,
        val calendarDisplayHijri: String,
        val calendarDisplayGregorian: String,
        val fontSizeHeader: String,
        val previewFormat: String,
        val mmssHeader: String,
        val mmssNever: String,
        val mmssValue: String,
        val saveBtn: String
    )

    private val localizations = mapOf(
        "tr" to ConfigStrings(
            title = "Widget Ayarları",
            themeHeader = "Arkaplan Teması",
            themeSystem = "Sistem Varsayılanı",
            themeLight = "Açık",
            themeDark = "Koyu",
            themeTransparent = "Saydam (Cam Görünümü)",
            calendarDisplayHeader = "Takvim Tarih Gösterimi",
            calendarDisplayBoth = "İkisi de (Hicri ve Miladi)",
            calendarDisplayHijri = "Yalnızca Hicri",
            calendarDisplayGregorian = "Yalnızca Miladi",
            fontSizeHeader = "Yazı Boyutu Ayarı",
            previewFormat = "Önizleme %d",
            mmssHeader = "Saniye Geri Sayımı Eşiği",
            mmssNever = "Her zaman HH:MM göster",
            mmssValue = "Son %d dk altında MM:SS göster",
            saveBtn = "AYARLARI KAYDET"
        ),
        "en" to ConfigStrings(
            title = "Widget Settings",
            themeHeader = "Background Theme",
            themeSystem = "System Default",
            themeLight = "Light",
            themeDark = "Dark",
            themeTransparent = "Transparent",
            calendarDisplayHeader = "Calendar Date Display",
            calendarDisplayBoth = "Both (Hijri & Gregorian)",
            calendarDisplayHijri = "Hijri only",
            calendarDisplayGregorian = "Gregorian only",
            fontSizeHeader = "Font Size",
            previewFormat = "Preview %d",
            mmssHeader = "Seconds Countdown Threshold",
            mmssNever = "Always show HH:MM",
            mmssValue = "MM:SS below %d min",
            saveBtn = "SAVE SETTINGS"
        ),
        "ar" to ConfigStrings(
            title = "إعدادات الأداة",
            themeHeader = "سمة الخلفية",
            themeSystem = "الافتراضي للنظام",
            themeLight = "فاتح",
            themeDark = "داكن",
            themeTransparent = "شفاف",
            calendarDisplayHeader = "عرض تاريخ التقويم",
            calendarDisplayBoth = "كلاهما (هجري وميلادي)",
            calendarDisplayHijri = "هجري فقط",
            calendarDisplayGregorian = "ميلادي فقط",
            fontSizeHeader = "حجم الخط",
            previewFormat = "معاينة %d",
            mmssHeader = "عتبة العد التنازلي",
            mmssNever = "عرض HH:MM دائماً",
            mmssValue = "MM:SS أقل من %d دقيقة",
            saveBtn = "حفظ الإعدادات"
        ),
        "es" to ConfigStrings(
            title = "Ajustes del Widget",
            themeHeader = "Tema de fondo",
            themeSystem = "Predeterminado del sistema",
            themeLight = "Claro",
            themeDark = "Oscuro",
            themeTransparent = "Transparente",
            calendarDisplayHeader = "Visualización de fecha",
            calendarDisplayBoth = "Ambos (Hiyri y Gregoriano)",
            calendarDisplayHijri = "Solo Hiyri",
            calendarDisplayGregorian = "Solo Gregoriano",
            fontSizeHeader = "Tamaño de fuente",
            previewFormat = "Vista previa %d",
            mmssHeader = "Umbral de cuenta regresiva",
            mmssNever = "Mostrar siempre HH:MM",
            mmssValue = "MM:SS bajo %d min",
            saveBtn = "GUARDAR AJUSTES"
        ),
        "fr" to ConfigStrings(
            title = "Paramètres du Widget",
            themeHeader = "Thème d'arrière-plan",
            themeSystem = "Système par défaut",
            themeLight = "Clair",
            themeDark = "Sombre",
            themeTransparent = "Transparent",
            calendarDisplayHeader = "Affichage de la date",
            calendarDisplayBoth = "Les deux (Hégirien & Grégorien)",
            calendarDisplayHijri = "Hégirien seulement",
            calendarDisplayGregorian = "Grégorien seulement",
            fontSizeHeader = "Taille de police",
            previewFormat = "Aperçu %d",
            mmssHeader = "Seuil du compte à rebours",
            mmssNever = "Toujours afficher HH:MM",
            mmssValue = "MM:SS sous %d min",
            saveBtn = "ENREGISTRER"
        ),
        "de" to ConfigStrings(
            title = "Widget-Einstellungen",
            themeHeader = "Hintergrund-Design",
            themeSystem = "Systemstandard",
            themeLight = "Hell",
            themeDark = "Dunkel",
            themeTransparent = "Transparent",
            calendarDisplayHeader = "Kalenderdatumsanzeige",
            calendarDisplayBoth = "Beide (Hijri & Gregorianisch)",
            calendarDisplayHijri = "Nur Hijri",
            calendarDisplayGregorian = "Nur Gregorianisch",
            fontSizeHeader = "Schriftgröße",
            previewFormat = "Vorschau %d",
            mmssHeader = "Countdown-Schwellenwert",
            mmssNever = "Immer HH:MM anzeigen",
            mmssValue = "MM:SS unter %d Min",
            saveBtn = "EINSTELLUNGEN SPEICHERN"
        ),
        "ru" to ConfigStrings(
            title = "Настройки виджета",
            themeHeader = "Тема фона",
            themeSystem = "По умолчанию в системе",
            themeLight = "Светлая",
            themeDark = "Тёмная",
            themeTransparent = "Прозрачная",
            calendarDisplayHeader = "Отображение даты в календаре",
            calendarDisplayBoth = "Оба (Хиджра и Григорианский)",
            calendarDisplayHijri = "Только Хиджра",
            calendarDisplayGregorian = "Только Григорианский",
            fontSizeHeader = "Размер шрифта",
            previewFormat = "Предпросмотр %d",
            mmssHeader = "Порог обратного отсчета",
            mmssNever = "Всегда HH:MM",
            mmssValue = "MM:SS менее %d мин",
            saveBtn = "СОХРАНИТЬ НАСТРОЙКИ"
        ),
        "fa" to ConfigStrings(
            title = "تنظیمات ویجت",
            themeHeader = "تم پس‌زمینه",
            themeSystem = "پیش‌فرض سیستم",
            themeLight = "روشن",
            themeDark = "تاریک",
            themeTransparent = "شفاف",
            calendarDisplayHeader = "نمایش تاریخ تقویم",
            calendarDisplayBoth = "هر دو (هجری و میلادی)",
            calendarDisplayHijri = "فقط هجری",
            calendarDisplayGregorian = "فقط میلادی",
            fontSizeHeader = "اندازه قلم",
            previewFormat = "پیش‌نمایش %d",
            mmssHeader = "آستانه شمارش معکوس",
            mmssNever = "همیشه نمایش HH:MM",
            mmssValue = "MM:SS زیر %d دقیقه",
            saveBtn = "ذخیره تنظیمات"
        ),
        "ur" to ConfigStrings(
            title = "ویجیٹ کی ترتیبات",
            themeHeader = "بیک گراؤنڈ تھیم",
            themeSystem = "سسٹم ڈیفالٹ",
            themeLight = "روشنی",
            themeDark = "ڈارک",
            themeTransparent = "شفاف",
            calendarDisplayHeader = "کیلنڈر کی تاریخ کا ڈسپلے",
            calendarDisplayBoth = "دونوں (ہجری اور عیسوی)",
            calendarDisplayHijri = "صرف ہجری",
            calendarDisplayGregorian = "صرف عیسوی",
            fontSizeHeader = "فونٹ سائز",
            previewFormat = "پیش نظارہ %d",
            mmssHeader = "الٹی گنتی کا حد",
            mmssNever = "ہمیشہ HH:MM دکھائیں",
            mmssValue = "MM:SS %d منٹ سے کم",
            saveBtn = "ترتیبات محفوظ کریں"
        ),
        "id" to ConfigStrings(
            title = "Pengaturan Widget",
            themeHeader = "Tema Latar Belakang",
            themeSystem = "Default Sistem",
            themeLight = "Terang",
            themeDark = "Gelap",
            themeTransparent = "Transparan",
            calendarDisplayHeader = "Tampilan Tanggal Kalender",
            calendarDisplayBoth = "Keduanya (Hijriah & Masehi)",
            calendarDisplayHijri = "Hanya Hijriah",
            calendarDisplayGregorian = "Hanya Masehi",
            fontSizeHeader = "Ukuran Font",
            previewFormat = "Pratinjau %d",
            mmssHeader = "Ambang Hitung Mundur",
            mmssNever = "Selalu tampilkan HH:MM",
            mmssValue = "MM:SS di bawah %d menit",
            saveBtn = "SIMPAN PENGATURAN"
        ),
        "zh" to ConfigStrings(
            title = "小工具设置",
            themeHeader = "背景主题",
            themeSystem = "系统默认",
            themeLight = "浅色",
            themeDark = "深色",
            themeTransparent = "透明",
            calendarDisplayHeader = "日历日期显示",
            calendarDisplayBoth = "两者 (伊斯兰历和公历)",
            calendarDisplayHijri = "仅伊斯兰历",
            calendarDisplayGregorian = "仅公历",
            fontSizeHeader = "字体大小设置",
            previewFormat = "预览 %d",
            mmssHeader = "倒计时阈值",
            mmssNever = "始终显示 HH:MM",
            mmssValue = "低于 %d 分钟显示 MM:SS",
            saveBtn = "保存设置"
        ),
        "ja" to ConfigStrings(
            title = "ウィジェット設定",
            themeHeader = "背景テーマ",
            themeSystem = "システムデフォルト",
            themeLight = "ライト",
            themeDark = "ダーク",
            themeTransparent = "透明",
            calendarDisplayHeader = "カレンダー日付表示",
            calendarDisplayBoth = "両方 (ヒジュラ暦 & グレゴリオ暦)",
            calendarDisplayHijri = "ヒジュラ暦のみ",
            calendarDisplayGregorian = "グレゴリオ暦のみ",
            fontSizeHeader = "フォントサイズ設定",
            previewFormat = "プレビュー %d",
            mmssHeader = "カウントダウン閾値",
            mmssNever = "常に HH:MM を表示",
            mmssValue = "%d分未満で MM:SS を表示",
            saveBtn = "設定を保存"
        )
    )

    private lateinit var dialogCard: LinearLayout
    private lateinit var textTitle: TextView
    private lateinit var textThemeHeader: TextView
    private lateinit var textCalendarDisplayHeader: TextView
    private lateinit var textFontSizeHeader: TextView
    private lateinit var textMmssHeader: TextView
    private lateinit var radioGroupTheme: RadioGroup
    private lateinit var radioSystem: RadioButton
    private lateinit var radioLight: RadioButton
    private lateinit var radioDark: RadioButton
    private lateinit var radioTransparent: RadioButton
    private lateinit var radioGroupCalendarDisplay: RadioGroup
    private lateinit var radioCalendarBoth: RadioButton
    private lateinit var radioCalendarHijri: RadioButton
    private lateinit var radioCalendarGregorian: RadioButton
    private lateinit var seekbarTextSize: SeekBar
    private lateinit var textPreview: TextView
    private lateinit var seekbarMmss: SeekBar
    private lateinit var textMmssValue: TextView
    private lateinit var btnSave: Button
    private lateinit var currentStrings: ConfigStrings

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intentExtras = intent.extras
        if (intentExtras != null) {
            appWidgetId = intentExtras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        val resultCancel = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_CANCELED, resultCancel)

        setContentView(R.layout.activity_widget_config)

        dialogCard = findViewById(R.id.dialogCard)
        textTitle = findViewById(R.id.textTitle)
        textThemeHeader = findViewById(R.id.textThemeHeader)
        textCalendarDisplayHeader = findViewById(R.id.textCalendarDisplayHeader)
        textFontSizeHeader = findViewById(R.id.textFontSizeHeader)
        textMmssHeader = findViewById(R.id.textMmssHeader)

        radioGroupTheme = findViewById(R.id.radioGroupTheme)
        radioSystem = findViewById(R.id.radioThemeSystem)
        radioLight = findViewById(R.id.radioThemeLight)
        radioDark = findViewById(R.id.radioThemeDark)
        radioTransparent = findViewById(R.id.radioThemeTransparent)

        radioGroupCalendarDisplay = findViewById(R.id.radioGroupCalendarDisplay)
        radioCalendarBoth = findViewById(R.id.radioCalendarBoth)
        radioCalendarHijri = findViewById(R.id.radioCalendarHijri)
        radioCalendarGregorian = findViewById(R.id.radioCalendarGregorian)

        seekbarTextSize = findViewById(R.id.seekbarTextSize)
        textPreview = findViewById(R.id.textPreview)

        seekbarMmss = findViewById(R.id.seekbarMmss)
        textMmssValue = findViewById(R.id.textMmssValue)

        btnSave = findViewById(R.id.btnSave)

        // Apply localization
        val storedLocale = PrayerWidgetStorage.readAppLocale(this).lowercase()
        val sysLocale = resources.configuration.locales[0].language.lowercase()
        val langCode = when {
            localizations.containsKey(storedLocale) -> storedLocale
            localizations.containsKey(sysLocale) -> sysLocale
            else -> "en"
        }
        currentStrings = localizations[langCode] ?: localizations["en"]!!

        if (langCode == "ar" || langCode == "fa" || langCode == "ur") {
            dialogCard.layoutDirection = View.LAYOUT_DIRECTION_RTL
        }

        textTitle.text = currentStrings.title
        textThemeHeader.text = currentStrings.themeHeader
        radioSystem.text = currentStrings.themeSystem
        radioLight.text = currentStrings.themeLight
        radioDark.text = currentStrings.themeDark
        radioTransparent.text = currentStrings.themeTransparent

        textCalendarDisplayHeader.text = currentStrings.calendarDisplayHeader
        radioCalendarBoth.text = currentStrings.calendarDisplayBoth
        radioCalendarHijri.text = currentStrings.calendarDisplayHijri
        radioCalendarGregorian.text = currentStrings.calendarDisplayGregorian

        textFontSizeHeader.text = currentStrings.fontSizeHeader
        textMmssHeader.text = currentStrings.mmssHeader
        btnSave.text = currentStrings.saveBtn

        // Load existing theme preference
        val currentTheme = PrayerWidgetStorage.readWidgetTheme(this)
        when (currentTheme) {
            "light" -> radioLight.isChecked = true
            "dark" -> radioDark.isChecked = true
            "transparent" -> radioTransparent.isChecked = true
            else -> radioSystem.isChecked = true
        }

        // Load existing calendar display preference
        val currentDisplay = PrayerWidgetStorage.readWidgetCalendarDisplay(this)
        when (currentDisplay) {
            "hijri" -> radioCalendarHijri.isChecked = true
            "gregorian" -> radioCalendarGregorian.isChecked = true
            else -> radioCalendarBoth.isChecked = true
        }

        applyDialogTheme(currentTheme)

        radioGroupTheme.setOnCheckedChangeListener { _, checkedId ->
            val selTheme = when (checkedId) {
                R.id.radioThemeLight -> "light"
                R.id.radioThemeDark -> "dark"
                R.id.radioThemeTransparent -> "transparent"
                else -> "system"
            }
            applyDialogTheme(selTheme)
        }

        // Text Size Seekbar
        val rawTextSize = PrayerWidgetStorage.readWidgetTextSize(this)
        val initialSizeInt = parseTextSizeToInt(rawTextSize)

        seekbarTextSize.max = 8
        val progress = (initialSizeInt - 10).coerceIn(0, 8)
        seekbarTextSize.progress = progress
        textPreview.text = String.format(currentStrings.previewFormat, 10 + progress)

        seekbarTextSize.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                val size = 10 + progress
                textPreview.text = String.format(currentStrings.previewFormat, size)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        // MM:SS Threshold Seekbar
        val currentMmss = PrayerWidgetStorage.readWidgetMmssThreshold(this)
        seekbarMmss.progress = currentMmss.coerceIn(0, 60)
        updateMmssLabel(currentMmss)

        seekbarMmss.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                updateMmssLabel(progress)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        btnSave.setOnClickListener {
            val selectedTheme = when (radioGroupTheme.checkedRadioButtonId) {
                R.id.radioThemeLight -> "light"
                R.id.radioThemeDark -> "dark"
                R.id.radioThemeTransparent -> "transparent"
                else -> "system"
            }

            val selectedCalendarDisplay = when (radioGroupCalendarDisplay.checkedRadioButtonId) {
                R.id.radioCalendarHijri -> "hijri"
                R.id.radioCalendarGregorian -> "gregorian"
                else -> "both"
            }

            val selectedSize = 10 + seekbarTextSize.progress
            val selectedMmss = seekbarMmss.progress

            PrayerWidgetStorage.saveWidgetTheme(this, selectedTheme)
            PrayerWidgetStorage.saveWidgetCalendarDisplay(this, selectedCalendarDisplay)
            PrayerWidgetStorage.saveWidgetTextSize(this, selectedSize.toString())
            PrayerWidgetStorage.saveWidgetMmssThreshold(this, selectedMmss)

            PrayerWidgetUpdater.updateAll(this)

            val resultOk = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultOk)
            finish()
        }
    }

    private fun updateMmssLabel(minutes: Int) {
        if (minutes == 0) {
            textMmssValue.text = currentStrings.mmssNever
        } else {
            textMmssValue.text = String.format(currentStrings.mmssValue, minutes)
        }
    }

    private fun applyDialogTheme(selectedTheme: String) {
        val isDark = when (selectedTheme) {
            "light" -> false
            "dark" -> true
            "transparent" -> true
            else -> {
                val nightMode = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                nightMode == Configuration.UI_MODE_NIGHT_YES
            }
        }

        if (isDark) {
            dialogCard.setBackgroundResource(R.drawable.widget_config_dialog_bg_dark)
            textTitle.setTextColor(Color.parseColor("#FFFFFFFF"))
            textThemeHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textCalendarDisplayHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textFontSizeHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textMmssHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textPreview.setTextColor(Color.parseColor("#B3FFFFFF"))
            textMmssValue.setTextColor(Color.parseColor("#B3FFFFFF"))

            radioSystem.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioLight.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioDark.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioTransparent.setTextColor(Color.parseColor("#FFFFFFFF"))

            radioCalendarBoth.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioCalendarHijri.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioCalendarGregorian.setTextColor(Color.parseColor("#FFFFFFFF"))

            btnSave.setBackgroundResource(R.drawable.btn_save_bg_dark)
            btnSave.setTextColor(Color.parseColor("#FFFFFFFF"))
        } else {
            dialogCard.setBackgroundResource(R.drawable.widget_config_dialog_bg)
            textTitle.setTextColor(Color.parseColor("#FF212121"))
            textThemeHeader.setTextColor(Color.parseColor("#FF757575"))
            textCalendarDisplayHeader.setTextColor(Color.parseColor("#FF757575"))
            textFontSizeHeader.setTextColor(Color.parseColor("#FF757575"))
            textMmssHeader.setTextColor(Color.parseColor("#FF757575"))
            textPreview.setTextColor(Color.parseColor("#FF757575"))
            textMmssValue.setTextColor(Color.parseColor("#FF757575"))

            radioSystem.setTextColor(Color.parseColor("#FF212121"))
            radioLight.setTextColor(Color.parseColor("#FF212121"))
            radioDark.setTextColor(Color.parseColor("#FF212121"))
            radioTransparent.setTextColor(Color.parseColor("#FF212121"))

            radioCalendarBoth.setTextColor(Color.parseColor("#FF212121"))
            radioCalendarHijri.setTextColor(Color.parseColor("#FF212121"))
            radioCalendarGregorian.setTextColor(Color.parseColor("#FF212121"))

            btnSave.setBackgroundResource(R.drawable.btn_save_bg)
            btnSave.setTextColor(Color.parseColor("#FF212121"))
        }
    }

    private fun parseTextSizeToInt(raw: String): Int {
        val num = raw.toIntOrNull()
        if (num != null) return num.coerceIn(10, 18)
        return when (raw) {
            "extraSmall" -> 10
            "small" -> 12
            "medium" -> 14
            "large" -> 16
            else -> 14
        }
    }
}
