import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/locale_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LocaleNotifier>();
    final currentCode = notifier.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              context.tr('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Card(
            child: Column(
              children: AppStrings.supported.map((loc) {
                final code = loc.languageCode;
                return RadioListTile<String>(
                  title: Text(context.tr('lang_$code')),
                  value: code,
                  groupValue: currentCode,
                  onChanged: (val) {
                    if (val != null) {
                      context.read<LocaleNotifier>().setLocale(Locale(val));
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
