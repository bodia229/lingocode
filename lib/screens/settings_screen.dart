import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/locale_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPrefs>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, context.tr('language')),
          Card(
            child: Column(
              children: AppStrings.supported.map((loc) {
                final code = loc.languageCode;
                return RadioListTile<String>(
                  title: Text(context.tr('lang_$code')),
                  value: code,
                  groupValue: prefs.locale.languageCode,
                  onChanged: (val) {
                    if (val != null) {
                      context.read<AppPrefs>().setLocale(Locale(val));
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, context.tr('theme')),
          Card(
            child: Column(
              children: [
                _themeRow(context, ThemeMode.system, 'theme_system', Icons.brightness_auto, prefs),
                _themeRow(context, ThemeMode.light, 'theme_light', Icons.light_mode, prefs),
                _themeRow(context, ThemeMode.dark, 'theme_dark', Icons.dark_mode, prefs),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, context.tr('feedback')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(context.tr('sound')),
                  secondary: const Icon(Icons.volume_up),
                  value: prefs.soundEnabled,
                  onChanged: (v) => context.read<AppPrefs>().setSoundEnabled(v),
                ),
                SwitchListTile(
                  title: Text(context.tr('haptic')),
                  secondary: const Icon(Icons.vibration),
                  value: prefs.hapticEnabled,
                  onChanged: (v) => context.read<AppPrefs>().setHapticEnabled(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _themeRow(
    BuildContext context,
    ThemeMode mode,
    String labelKey,
    IconData icon,
    AppPrefs prefs,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(context.tr(labelKey)),
      secondary: Icon(icon),
      value: mode,
      groupValue: prefs.themeMode,
      onChanged: (val) {
        if (val != null) {
          context.read<AppPrefs>().setThemeMode(val);
        }
      },
    );
  }
}
