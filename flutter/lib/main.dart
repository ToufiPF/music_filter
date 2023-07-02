import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import 'models/catalog.dart';
import 'models/isar_catalog.dart';
import 'models/isar_state_store.dart';
import 'models/music.dart';
import 'models/state_store.dart';
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
  WidgetsBinding.instance.addObserver(permissions);

  final rootFolder = RootFolderNotifier(
    prefService: prefService,
    prefName: Pref.rootFolder.name,
  );
  final PlayerQueueNotifier playlist = JustAudioQueueNotifier();
  final PlayerStateController player = JustAudioPlayerController();
  player.attachPlaylistController(playlist);

  final docDir = await getApplicationDocumentsDirectory();
  final isarDir = Directory('${docDir.path}/isar_db');
  await isarDir.create(recursive: true);

  final isar = await Isar.open(
    [MusicSchema, MusicStateSchema],
    directory: isarDir.path,
  );
  final Catalog catalog = IsarCatalog(isarDb: isar);
  final StateStore stateStore = IsarStateStore(isarDb: isar);

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
      Provider.value(value: stateStore),
    ],
    child: PrefService(
      service: prefService,
      child: MyApp(
        rootFolder: rootFolder,
        catalog: catalog,
      ),
    ),
  ));
}

class MyApp extends StatefulWidget {
  static const String title = "MusicFilter";
  static const String version = "1.0.0";

  const MyApp({
    super.key,
    required this.rootFolder,
    required this.catalog,
  });

  final RootFolderNotifier rootFolder;
  final Catalog catalog;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.rootFolder.addListener(_onRootChanged);

    // refresh catalog from disk without scanning
    final root = widget.rootFolder.rootFolder?.path;
    if (root != null) {
      widget.catalog.refresh(root);
    }
  }

  @override
  void dispose() {
    widget.rootFolder.removeListener(_onRootChanged);
    super.dispose();
  }

  void _onRootChanged() {
    final root = widget.rootFolder.rootFolder;
    if (root != null) {
      widget.catalog.scan(root);
    }
  }

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
    const required = [
      // PermissionGroup.storage,
      PermissionGroup.media,
    ];

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
