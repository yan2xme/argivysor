// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Detect`
  String get detect {
    return Intl.message(
      'Detect',
      name: 'detect',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message(
      'Library',
      name: 'library',
      desc: '',
      args: [],
    );
  }

  /// `Chatbot`
  String get chatbot {
    return Intl.message(
      'Chatbot',
      name: 'chatbot',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Good Day!`
  String get goodDay {
    return Intl.message(
      'Good Day!',
      name: 'goodDay',
      desc: '',
      args: [],
    );
  }

  /// `Detect plant diseases easily.`
  String get detectDisease {
    return Intl.message(
      'Detect plant diseases easily.',
      name: 'detectDisease',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Close Menu`
  String get closeMenu {
    return Intl.message(
      'Close Menu',
      name: 'closeMenu',
      desc: '',
      args: [],
    );
  }

  /// `Open Menu`
  String get openMenu {
    return Intl.message(
      'Open Menu',
      name: 'openMenu',
      desc: '',
      args: [],
    );
  }

  /// `AgriVysor`
  String get appName {
    return Intl.message(
      'AgriVysor',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Good Morning!`
  String get magandangUmaga {
    return Intl.message(
      'Good Morning!',
      name: 'magandangUmaga',
      desc: '',
      args: [],
    );
  }

  String? get classificationError => null;

  String? get noDiseaseDetected => null;

  String? get noDetectionMessage => null;

  String? get ok => null;
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'tl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
