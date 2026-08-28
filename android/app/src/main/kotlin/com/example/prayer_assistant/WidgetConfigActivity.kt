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
        val fontSizeHeader: String,
        val previewFormat: String,
        val saveBtn: String
    )

    private val localizations = mapOf(
        "tr" to ConfigStrings(
            title = "Widget Ayarları",
            themeHeader = "Arkaplan Teması",
            themeSystem = "Telefon Ayarlarıyla Eşleştir",
            themeLight = "Açık",
            themeDark = "Koyu",
            fontSizeHeader = "Yazı Boyutu Ayarı",
            previewFormat = "Önizleme %d",
            saveBtn = "AYARLARI KAYDET"
        ),
        "en" to ConfigStrings(
            title = "Widget Settings",
            themeHeader = "Background Theme",
            themeSystem = "Match Phone Settings",
            themeLight = "Light",
            themeDark = "Dark",
            fontSizeHeader = "Font Size Setting",
            previewFormat = "Preview %d",
            saveBtn = "SAVE SETTINGS"
        ),
        "ar" to ConfigStrings(
            title = "إعدادات الأداة",
            themeHeader = "سمة الخلفية",
            themeSystem = "مطابقة إعدادات الجهاز",
            themeLight = "فاتح",
            themeDark = "داكن",
            fontSizeHeader = "حجم الخط",
            previewFormat = "معاينة %d",
            saveBtn = "حفظ الإعدادات"
        ),
        "es" to ConfigStrings(
            title = "Ajustes del Widget",
            themeHeader = "Tema de fondo",
            themeSystem = "Coincidir con el teléfono",
            themeLight = "Claro",
            themeDark = "Oscuro",
            fontSizeHeader = "Tamaño de fuente",
            previewFormat = "Vista previa %d",
            saveBtn = "GUARDAR AJUSTES"
        ),
        "fr" to ConfigStrings(
            title = "Paramètres du Widget",
            themeHeader = "Thème d'arrière-plan",
            themeSystem = "Harmoniser avec le téléphone",
            themeLight = "Clair",
            themeDark = "Sombre",
            fontSizeHeader = "Taille de police",
            previewFormat = "Aperçu %d",
            saveBtn = "ENREGISTRER"
        ),
        "de" to ConfigStrings(
            title = "Widget-Einstellungen",
            themeHeader = "Hintergrund-Design",
            themeSystem = "An Systemeinstellungen anpassen",
            themeLight = "Hell",
            themeDark = "Dunkel",
            fontSizeHeader = "Schriftgröße",
            previewFormat = "Vorschau %d",
            saveBtn = "EINSTELLUNGEN SPEICHERN"
        ),
        "ru" to ConfigStrings(
            title = "Настройки виджета",
            themeHeader = "Тема фона",
            themeSystem = "Как в системе",
            themeLight = "Светлая",
            themeDark = "Тёмная",
            fontSizeHeader = "Размер шрифта",
            previewFormat = "Предпросмотр %d",
            saveBtn = "СОХРАНИТЬ НАСТРОЙКИ"
        ),
        "fa" to ConfigStrings(
            title = "تنظیمات ویجت",
            themeHeader = "تم پس‌زمینه",
            themeSystem = "هماهنگ با تنظیمات گوشی",
            themeLight = "روشن",
            themeDark = "تاریک",
            fontSizeHeader = "اندازه قلم",
            previewFormat = "پیش‌نمایش %d",
            saveBtn = "ذخیره تنظیمات"
        ),
        "ur" to ConfigStrings(
            title = "ویجیٹ کی ترتیبات",
            themeHeader = "بیک گراؤنڈ تھیم",
            themeSystem = "فون ترتیبات کے مطابق",
            themeLight = "روشنی",
            themeDark = "ڈارک",
            fontSizeHeader = "فونٹ سائز",
            previewFormat = "پیش نظارہ %d",
            saveBtn = "ترتیبات محفوظ کریں"
        ),
        "id" to ConfigStrings(
            title = "Pengaturan Widget",
            themeHeader = "Tema Latar Belakang",
            themeSystem = "Sesuaikan Pengaturan Ponsel",
            themeLight = "Terang",
            themeDark = "Gelap",
            fontSizeHeader = "Ukuran Font",
            previewFormat = "Pratinjau %d",
            saveBtn = "SIMPAN PENGATURAN"
        ),
        "zh" to ConfigStrings(
            title = "小工具设置",
            themeHeader = "背景主题",
            themeSystem = "跟随系统设置",
            themeLight = "浅色",
            themeDark = "深色",
            fontSizeHeader = "字体大小设置",
            previewFormat = "预览 %d",
            saveBtn = "保存设置"
        ),
        "ja" to ConfigStrings(
            title = "ウィジェット設定",
            themeHeader = "背景テーマ",
            themeSystem = "端末の設定に合わせる",
            themeLight = "ライト",
            themeDark = "ダーク",
            fontSizeHeader = "フォントサイズ設定",
            previewFormat = "プレビュー %d",
            saveBtn = "設定を保存"
        )
    )

    private lateinit var dialogCard: LinearLayout
    private lateinit var textTitle: TextView
    private lateinit var textThemeHeader: TextView
    private lateinit var textFontSizeHeader: TextView
    private lateinit var radioGroupTheme: RadioGroup
    private lateinit var radioSystem: RadioButton
    private lateinit var radioLight: RadioButton
    private lateinit var radioDark: RadioButton
    private lateinit var seekbarTextSize: SeekBar
    private lateinit var textPreview: TextView
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
        textFontSizeHeader = findViewById(R.id.textFontSizeHeader)
        radioGroupTheme = findViewById(R.id.radioGroupTheme)
        radioSystem = findViewById(R.id.radioThemeSystem)
        radioLight = findViewById(R.id.radioThemeLight)
        radioDark = findViewById(R.id.radioThemeDark)
        seekbarTextSize = findViewById(R.id.seekbarTextSize)
        textPreview = findViewById(R.id.textPreview)
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
        textFontSizeHeader.text = currentStrings.fontSizeHeader
        btnSave.text = currentStrings.saveBtn

        // Load existing theme preference
        val currentTheme = PrayerWidgetStorage.readWidgetTheme(this)
        when (currentTheme) {
            "light" -> radioLight.isChecked = true
            "dark" -> radioDark.isChecked = true
            else -> radioSystem.isChecked = true
        }

        applyDialogTheme(currentTheme)

        radioGroupTheme.setOnCheckedChangeListener { _, checkedId ->
            val selTheme = when (checkedId) {
                R.id.radioThemeLight -> "light"
                R.id.radioThemeDark -> "dark"
                else -> "system"
            }
            applyDialogTheme(selTheme)
        }

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

        btnSave.setOnClickListener {
            val selectedTheme = when (radioGroupTheme.checkedRadioButtonId) {
                R.id.radioThemeLight -> "light"
                R.id.radioThemeDark -> "dark"
                else -> "system"
            }

            val selectedSize = 10 + seekbarTextSize.progress

            PrayerWidgetStorage.saveWidgetTheme(this, selectedTheme)
            PrayerWidgetStorage.saveWidgetTextSize(this, selectedSize.toString())

            PrayerWidgetUpdater.updateAll(this)

            val resultOk = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultOk)
            finish()
        }
    }

    private fun applyDialogTheme(selectedTheme: String) {
        val isDark = when (selectedTheme) {
            "light" -> false
            "dark" -> true
            else -> {
                val nightMode = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                nightMode == Configuration.UI_MODE_NIGHT_YES
            }
        }

        if (isDark) {
            dialogCard.setBackgroundResource(R.drawable.widget_config_dialog_bg_dark)
            textTitle.setTextColor(Color.parseColor("#FFFFFFFF"))
            textThemeHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textFontSizeHeader.setTextColor(Color.parseColor("#B3FFFFFF"))
            textPreview.setTextColor(Color.parseColor("#B3FFFFFF"))

            radioSystem.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioLight.setTextColor(Color.parseColor("#FFFFFFFF"))
            radioDark.setTextColor(Color.parseColor("#FFFFFFFF"))

            btnSave.setBackgroundResource(R.drawable.btn_save_bg_dark)
            btnSave.setTextColor(Color.parseColor("#FFFFFFFF"))
        } else {
            dialogCard.setBackgroundResource(R.drawable.widget_config_dialog_bg)
            textTitle.setTextColor(Color.parseColor("#FF212121"))
            textThemeHeader.setTextColor(Color.parseColor("#FF757575"))
            textFontSizeHeader.setTextColor(Color.parseColor("#FF757575"))
            textPreview.setTextColor(Color.parseColor("#FF757575"))

            radioSystem.setTextColor(Color.parseColor("#FF212121"))
            radioLight.setTextColor(Color.parseColor("#FF212121"))
            radioDark.setTextColor(Color.parseColor("#FF212121"))

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
