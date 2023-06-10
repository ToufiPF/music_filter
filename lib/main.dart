import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import 'providers/permissions.dart';
import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final permissions = PermissionsNotifier();

  final prefService = await PrefServiceShared.init(
    prefix: "",
    defaults: Pref.getDefaultValues(),
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: permissions),
    ],
    child: PrefService(
      service: prefService,
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  static const String title = "MusicFilter";

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: title,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Settings(),
      );
}
