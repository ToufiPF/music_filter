import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import 'pages/home.dart';
import 'providers/active_tabs.dart';
import 'providers/permissions.dart';
import 'providers/playlist.dart';
import 'providers/root_folder.dart';
import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'ch.epfl.music_filter',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationClickStartsActivity: true,
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
  );

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
  final tabs = ActiveTabsNotifier(prefService);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: permissions),
      ChangeNotifierProvider.value(value: rootFolder),
      ChangeNotifierProvider.value(value: playlist),
      ChangeNotifierProvider.value(value: tabs),
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
            '/home': _homePage,
            '/settings': _settingsPage,
            '/licenses': (_) => LicensePage(
                  applicationName: MyApp.title,
                  applicationVersion: MyApp.version,
                  applicationIcon: null,
                  applicationLegalese: null,
                ),
          });

  Widget _homePage(BuildContext context) => HomePage();

  Widget _settingsPage(BuildContext context) => SettingsPage();
}
