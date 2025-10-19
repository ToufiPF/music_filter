import 'dart:io';

import 'package:flutter/material.dart';
import 'services/music_store_service.dart';
import 'services/playlist_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import 'data/entities/music.dart';

import 'notification.dart';
import 'pages/home.dart';
import 'providers/active_tabs.dart';
import 'providers/folders.dart';
import 'providers/permissions.dart';
import 'providers/player.dart';
import 'providers/root_folder.dart';
import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await PrefServiceShared.init(
    prefix: "",
    defaults: Pref.getDefaultValues(),
  );

  final permissions = await PermissionsNotifier.initialize();
  WidgetsBinding.instance.addObserver(permissions);

  final docDir = await getApplicationDocumentsDirectory();
  final isarDir = Directory(p.join(docDir.path, 'isar_db'));
  await isarDir.create(recursive: true);
  final isar = await Isar.open(
    [MusicSchema],
    directory: isarDir.path,
  );

  final playlist = PlaylistService();
  final musicStore = MusicStoreService(isar);

  final rootFolder = RootFolderNotifier(
    prefService: prefService,
    prefName: Pref.rootFolder.name,
    store: musicStore
  );

  await NotifHandler.init(
    queue: playlist,
    musicStore: musicStore,
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
      Provider.value(value: playlist),
      Provider.value(value: player),
      Provider.value(value: musicStore),
    ],
    child: PrefService(
      service: prefService,
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  static const String title = "MusicFilter";
  static const String version = "1.1.0";

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
            : _requestPermissions(context, perm, required));
  }

  Widget _requestPermissions(BuildContext context, PermissionsNotifier perm,
          List<PermissionGroup> required) =>
      Scaffold(
        body: Center(
          child: ElevatedButton(
            child: Text("Request permissions"),
            onPressed: () => perm.requestOrGoToSettings(required),
          ),
        ),
      );

  Widget _homePage(BuildContext context) => HomePage();

  Widget _settingsPage(BuildContext context) => SettingsPage();
}
