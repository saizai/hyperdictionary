TRANSLATE_LOCALES = Google::Language::Languages.keys.sort - ['']
# usage: Translate.t text, source_locale, target_locale
# all locales are base (eg 'en') except Chinese: zh, zh-CN, zh-TW