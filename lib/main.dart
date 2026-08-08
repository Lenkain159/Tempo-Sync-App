import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

final ValueNotifier<TempoTheme> currentTheme =
    ValueNotifier(TempoTheme.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<TempoTheme>(
      valueListenable: currentTheme,

      builder: (context, theme, child) {

        ThemeData appTheme;

        switch (theme) {

          case TempoTheme.dark:
            appTheme = darkTheme;
            break;

          case TempoTheme.highContrast:
            appTheme = highContrastTheme;
            break;

          default:
            appTheme = lightTheme;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: const HomePage(),
        );
      },
    );
  }
}