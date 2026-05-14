import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:translator/translator.dart';

class ownerLanguageScreen extends StatefulWidget {
  const ownerLanguageScreen({super.key});

  @override
  State<ownerLanguageScreen> createState() => _ownerLanguageScreenState();
}
ValueNotifier<String> ownerAppLanguageNotifier = ValueNotifier(
  "en",
); // default English

final translator = GoogleTranslator();

Future<String> getTranslatedText(String text, String langCode) async {
  if (langCode == "en") return text; // no need to translate
  var translation = await translator.translate(text, to: langCode);
  return translation.text;
}
class _ownerLanguageScreenState extends State<ownerLanguageScreen> {
  final List<Map<String, String>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'Hindi | हिन्दी'},
    {'code': 'mr', 'label': 'Marathi | मराठी'},
    {'code': 'ta', 'label': 'Tamil | தமிழ்'},
    {'code': 'te', 'label': 'Telugu | తెలుగు'},
    {'code': 'kn', 'label': 'Kannada | ಕನ್ನಡ'},
    {'code': 'ml', 'label': 'Malayalam | മലയാളം'},
    {'code': 'bn', 'label': 'Bengali | বাংলা'},
  ];

  String? selectedCode = ownerAppLanguageNotifier.value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;
        final primaryColor = theme.colorScheme.primary;

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Select Language'),
              leading: const BackButton(),
              backgroundColor: primaryColor, // Dynamic theme color
            ),
            body: ListView(
              children: languages.map((language) {
                return RadioListTile<String>(
                  title: Text(language['label']!),
                  value: language['code']!,
                  groupValue: selectedCode,
                  onChanged: (String? value) async {
                    await OwnerThemeLangSettings.saveSelectedLocale(value);
        log(
          "sharedlang: ${await OwnerThemeLangSettings(locale: null, theme: null).loadSelectedLocale()}",
        );

        setState(() {
          ownerAppLanguageNotifier.value = value!;
          log("language: ${ownerAppLanguageNotifier.value}");
        });
                    setState(() {
                      selectedCode = value;
                    });
                    // Update app language logic here
                  },
                  activeColor: primaryColor, // Dynamic theme color
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
