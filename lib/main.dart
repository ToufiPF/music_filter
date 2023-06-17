import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import 'pages/home.dart';
import 'providers/permissions.dart';
import 'providers/playlist.dart';
import 'providers/root_folder.dart';
import 'settings/settings.dart';
import 'widget/folder_authorization_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await PrefServiceShared.init(
    prefix: "",
    defaults: Pref.getDefaultValues(),
  );

  debugPrint("Preferences: ${prefService.getKeys()}");

  final permissions = PermissionsNotifier();
  final rootFolder = RootFolderNotifier(
    prefService: prefService,
    prefName: Pref.rootFolder.name,
  );
  final playlist = PlaylistNotifier();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: permissions),
      ChangeNotifierProvider.value(value: rootFolder),
      ChangeNotifierProvider.value(value: playlist),
    ],
    child: PrefService(
      service: prefService,
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  static const String title = "MusicFilter";
  static const String version = "1.0.0";

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/home',
          routes: {
            '/initial': _initialPage,
            '/home': _homePage,
            '/settings': _settingsPage,
            '/licenses': (_) => LicensePage(
                  applicationName: MyApp.title,
                  applicationVersion: MyApp.version,
                  applicationIcon: null,
                  applicationLegalese: null,
                ),
          });

  Widget _initialPage(BuildContext context) =>
      Consumer<RootFolderNotifier>(builder: (context, provider, child) {
        if (provider.rootFolder != null) {
          return _homePage(context);
        } else {
          return Center(child: FolderAuthorizationWidget());
        }
      });

  Widget _homePage(BuildContext context) => HomePage();

  Widget _settingsPage(BuildContext context) => SettingsPage();
}
