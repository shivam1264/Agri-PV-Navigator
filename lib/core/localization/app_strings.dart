import 'package:flutter/widgets.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common & Navigation
      'app_title': 'Agri-PV Navigator',
      'home': 'Home',
      'farms': 'Farms',
      'design': 'Design',
      'reports': 'Reports',
      'profile': 'Profile',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'success': 'Success',
      'error': 'Error',
      'save_changes': 'Save Changes',
      'save_settings': 'Save Settings',

      // Profile Screen
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'enter_name': 'Enter your full name',
      'name_required': 'Name is required',
      'phone_number': 'Phone Number',
      'phone_hint': 'e.g. +91 98765 43210',
      'profile_updated': 'Profile updated successfully!',
      'profile_update_failed': 'Failed to update profile',
      'stat_farms': 'Farms',
      'stat_total_area': 'Total Area',
      'stat_designs': 'Designs',
      'my_farms': 'My Farms',
      'app_settings': 'App Settings',
      'help_support': 'Help & Support',
      'about': 'About',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to log out?',
      'quick_prefs': 'Quick Preferences',

      // Settings Screen - Sections
      'settings': 'Settings',
      'appearance': 'Appearance',
      'notifications': 'Notifications',
      'security_accessibility': 'Security & Accessibility',
      'privacy_security': 'Privacy & Security',
      'accessibility': 'Accessibility',

      // Settings - Theme
      'theme': 'Theme',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'theme_system': 'System Default',
      'theme_light_desc': 'Best for outdoor daytime viewing',
      'theme_dark_desc': 'Reduces glare and saves battery',
      'theme_system_desc': 'Follows your device system setting',
      'choose_theme': 'Choose Theme',

      // Settings - Language
      'language': 'Language',
      'choose_language': 'Choose Language',
      'lang_english': 'English',
      'lang_hindi': 'Hindi (हिंदी)',
      'lang_english_sub': 'Default system language',
      'lang_hindi_sub': 'भारतीय किसानों के लिए हिंदी भाषा',

      // Settings - Units
      'units': 'Units System',
      'choose_units': 'Select Measurement Units',
      'units_metric': 'Metric (SI, acres)',
      'units_imperial': 'Imperial (ft, acres)',
      'units_hectares': 'Hectares (ha)',
      'units_metric_desc': 'Meters (m), Acres (ac), Liters (L), Kilowatts (kW)',
      'units_imperial_desc': 'Feet (ft), Acres (ac), Gallons (gal), Kilowatts (kW)',
      'units_hectares_desc': 'Meters (m), Hectares (ha), Liters (L), Kilowatts (kW)',
      'unit_area_label': 'Area Unit',
      'unit_height_label': 'Clearance Unit',
      'unit_water_label': 'Water Unit',
      'unit_power_label': 'Solar Power Unit',

      // Settings - Notifications
      'notif_title': 'Push Notifications',
      'notif_desc': 'Receive weather alerts, report readiness & advice',

      // Accessibility Sheet
      'accessibility_title': 'Accessibility & Display',
      'text_size': 'Text Size',
      'text_preview': 'Preview text size',
      'high_contrast': 'High Contrast Mode',
      'high_contrast_desc': 'Increase color contrast for enhanced outdoor visibility',
      'large_targets': 'Large Touch Targets',
      'large_targets_desc': 'Expands interactive buttons for easy tapping in field',
      'reduce_motion': 'Reduce Motion',
      'reduce_motion_desc': 'Minimizes animations for faster, smoother navigation',
      'reset_defaults': 'Reset to Defaults',
      'settings_saved': 'Settings saved successfully',

      // Privacy Sheet
      'location_sharing': 'Location Sharing',
      'location_sharing_desc': 'Allow GPS access for boundary mapping & solar radiation',
      'usage_analytics': 'Usage Analytics',
      'usage_analytics_desc': 'Help improve Agri-PV Navigator with anonymous data',
      'crash_reporting': 'Crash Reporting',
      'crash_reporting_desc': 'Automatically notify engineers to resolve bugs faster',
      'biometric_lock': 'Biometric Lock',
      'biometric_lock_desc': 'Protect farm designs with fingerprint / Face ID',
    },
    'hi': {
      // Common & Navigation
      'app_title': 'एग्री-पीवी नेविगेटर',
      'home': 'होम',
      'farms': 'खेत',
      'design': 'डिज़ाइन',
      'reports': 'रिपोर्ट्स',
      'profile': 'प्रोफ़ाइल',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'close': 'बंद करें',
      'success': 'सफल',
      'error': 'त्रुटि',
      'save_changes': 'बदलाव सहेजें',
      'save_settings': 'सेटिंग्स सहेजें',

      // Profile Screen
      'my_profile': 'मेरी प्रोफ़ाइल',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'full_name': 'पूरा नाम',
      'enter_name': 'अपना पूरा नाम दर्ज करें',
      'name_required': 'नाम आवश्यक है',
      'phone_number': 'फ़ोन नंबर',
      'phone_hint': 'उदा. +91 98765 43210',
      'profile_updated': 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई!',
      'profile_update_failed': 'प्रोफ़ाइल अपडेट करने में विफल',
      'stat_farms': 'कुल खेत',
      'stat_total_area': 'कुल क्षेत्रफल',
      'stat_designs': 'डिज़ाइन्स',
      'my_farms': 'मेरे खेत',
      'app_settings': 'ऐप सेटिंग्स',
      'help_support': 'सहायता और समर्थन',
      'about': 'हमारे बारे में',
      'logout': 'लॉग आउट',
      'logout_confirm': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
      'quick_prefs': 'त्वरित प्राथमिकताएँ',

      // Settings Screen - Sections
      'settings': 'सेटिंग्स',
      'appearance': 'दिखावट (अपीयरेंस)',
      'notifications': 'सूचनाएं',
      'security_accessibility': 'सुरक्षा एवं पहुंच क्षमता',
      'privacy_security': 'गोपनीयता और सुरक्षा',
      'accessibility': 'पहुंच क्षमता (एक्सेसिबिलिटी)',

      // Settings - Theme
      'theme': 'थीम',
      'theme_light': 'लाइट मोड (दिन)',
      'theme_dark': 'डार्क मोड (रात)',
      'theme_system': 'सिस्टम डिफ़ॉल्ट',
      'theme_light_desc': 'खेत में दिन की तेज़ रोशनी के लिए उत्तम',
      'theme_dark_desc': 'आंखों पर तनाव कम करता है और बैटरी बचाता है',
      'theme_system_desc': 'आपके फ़ोन की डिफ़ॉल्ट थीम के अनुसार',
      'choose_theme': 'थीम चुनें',

      // Settings - Language
      'language': 'भाषा (Language)',
      'choose_language': 'भाषा चुनें',
      'lang_english': 'English (अंग्रेज़ी)',
      'lang_hindi': 'हिंदी (Hindi)',
      'lang_english_sub': 'Default system language',
      'lang_hindi_sub': 'भारतीय किसानों के लिए हिंदी भाषा',

      // Settings - Units
      'units': 'माप प्रणाली',
      'choose_units': 'माप इकाइयाँ चुनें',
      'units_metric': 'मीट्रिक (मीटर, एकड़)',
      'units_imperial': 'इंपीरियल (फ़ीट, एकड़)',
      'units_hectares': 'हेक्टेयर (हे.)',
      'units_metric_desc': 'मीटर (m), एकड़ (ac), लीटर (L), किलोवाट (kW)',
      'units_imperial_desc': 'फ़ीट (ft), एकड़ (ac), गैलन (gal), किलोवाट (kW)',
      'units_hectares_desc': 'मीटर (m), हेक्टेयर (ha), लीटर (L), किलोवाट (kW)',
      'unit_area_label': 'क्षेत्रफल इकाई',
      'unit_height_label': 'ऊंचाई इकाई',
      'unit_water_label': 'जल बचत इकाई',
      'unit_power_label': 'सौर ऊर्जा इकाई',

      // Settings - Notifications
      'notif_title': 'पुश नोटिफिकेशन',
      'notif_desc': 'मौसम अपडेट, रिपोर्ट और कृषि सलाह तुरंत पाएं',

      // Accessibility Sheet
      'accessibility_title': 'पहुंच क्षमता और डिस्प्ले',
      'text_size': 'अक्षरों का आकार',
      'text_preview': 'टेक्स्ट आकार का पूर्वावलोकन',
      'high_contrast': 'हाई कंट्रास्ट मोड',
      'high_contrast_desc': 'धूप में स्पष्ट देखने के लिए रंगों का कंट्रास्ट बढ़ाएं',
      'large_targets': 'बड़े टच बटन',
      'large_targets_desc': 'खेत में काम करते समय आसानी से छूने के लिए बड़े बटन',
      'reduce_motion': 'एनीमेशन कम करें',
      'reduce_motion_desc': 'ऐप को तेज़ और सरल बनाने के लिए एनीमेशन न्यूनतम करें',
      'reset_defaults': 'डिफ़ॉल्ट पर रीसेट करें',
      'settings_saved': 'सेटिंग्स सफलतापूर्वक सहेजी गईं',

      // Privacy Sheet
      'location_sharing': 'स्थान साझाकरण (GPS)',
      'location_sharing_desc': 'खेत की मैपिंग और सौर ऊर्जा आंकलन के लिए GPS की अनुमति दें',
      'usage_analytics': 'उपयोग एनालिटिक्स',
      'usage_analytics_desc': 'ऐप को बेहतर बनाने के लिए अनाम डेटा साझा करें',
      'crash_reporting': 'क्रैश रिपोर्टिंग',
      'crash_reporting_desc': 'तकनीकी समस्याओं को तुरंत ठीक करने के लिए रिपोर्ट भेजें',
      'biometric_lock': 'बायोमेट्रिक सुरक्षा',
      'biometric_lock_desc': 'फ़िंगरप्रिंट या फ़ेस आईडी से ऐप लॉक करें',
    },
  };

  static String get(String key, {String language = 'English'}) {
    final code = language.toLowerCase().contains('hindi') ? 'hi' : 'en';
    final langMap = _localizedValues[code] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']![key] ?? key;
  }
}

extension AppStringsExtension on BuildContext {
  String tr(String key, {String language = 'English'}) {
    return AppStrings.get(key, language: language);
  }
}
