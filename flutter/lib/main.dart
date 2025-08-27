import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import 'data/entities/music.dart';

import 'models/catalog.dart';
import 'models/catalog_volatile.dart';
import 'models/state_store.dart';
import 'models/state_store_volatile.dart';
import 'notification.dart';
import 'pages/home.dart';
import 'providers/active_tabs.dart';
import 'providers/folders.dart';
import 'providers/permissions.dart';
import 'providers/player.dart';
import 'providers/playlist.dart';
import 'providers/root_folder.dart';
import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'ch.epfl.music_filter',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationClickStartsActivity: true,
  //   androidNotificationOngoing: false,
  //   androidStopForegroundOnPause: true,
  // );

  final prefService = await PrefServiceShared.init(
    prefix: "",
    defaults: Pref.getDefaultValues(),
  );

  final permissions = await PermissionsNotifier.initialize();
  WidgetsBinding.instance.addObserver(permissions);

  final rootFolder = RootFolderNotifier(
    prefService: prefService,
    prefName: Pref.rootFolder.name,
  );
  final PlayerQueueNotifier playlist = JustAudioQueueNotifier(rootFolder);

  final docDir = await getApplicationDocumentsDirectory();
  final isarDir = Directory('${docDir.path}/isar_db');
  await isarDir.create(recursive: true);

  final isar = await Isar.open(
    [MusicSchema],
    directory: isarDir.path,
  );
  final Catalog catalog =
      VolatileCatalog(rootFolder); //IsarCatalog(isarDb: isar);
  final StateStore stateStore =
      VolatileStateStore(rootFolder); // IsarStateStore(isarDb: isar);

  await NotifHandler.init(
    queue: playlist,
    stateStore: stateStore,
  );

  final PlayerStateController player = JustAudioPlayerController();
  player.attachPlaylistController(playlist);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => ActiveTabsNotifier(prefService: prefService)),
      ChangeNotifierProvider(
          create: (_) => ShowHiddenFilesNotifier(prefService: prefService)),
      ChangeNotifierProvider(
          create: (_) => ShowEmptyFoldersNotifier(prefService: prefService)),
      ChangeNotifierProvider.value(value: permissions),
      ChangeNotifierProvider.value(value: rootFolder),
      ChangeNotifierProvider.value(value: playlist),
      Provider.value(value: player),
      ChangeNotifierProvider.value(value: catalog),
      ChangeNotifierProvider.value(value: stateStore),
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

  @override
  Widget build(BuildContext context) => MaterialApp(
          title: MyApp.title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/initial',
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

  Widget _initialPage(BuildContext context) {
    const required = [PermissionGroup.notif, PermissionGroup.storage];

    return Consumer<PermissionsNotifier>(
        builder: (context, perm, child) => perm
                .getStatuses(required)
                .every((e) => e == PermissionStatus.granted)
            ? _homePage(context)
            : Scaffold(
                body: Center(
                  child: ElevatedButton(
                    child: Text("Request permissions"),
                    onPressed: () => perm.requestOrGoToSettings(required),
                  ),
                ),
              ));
  }

  Widget _homePage(BuildContext context) => HomePage();

  Widget _settingsPage(BuildContext context) => SettingsPage();
}
