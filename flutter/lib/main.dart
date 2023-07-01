import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import 'models/isar_store.dart';
import 'models/music.dart';
import 'models/store.dart';
import 'pages/home.dart';
import 'providers/active_tabs.dart';
import 'providers/folders.dart';
import 'providers/music_hierarchy.dart';
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

  final isar = await Isar.open([MusicSchema], directory: isarDir.path);
  final StateStore store = IsarStateStore(isar.musics);

  final MusicHierarchyNotifier musics = MusicHierarchyNotifierImpl();

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
      ChangeNotifierProvider.value(value: musics),
      Provider.value(value: player),
      Provider.value(value: store),
    ],
    child: PrefService(
      service: prefService,
      child: MyApp(
        rootFolder: rootFolder,
        hierarchy: musics,
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
    required this.hierarchy,
  });

  final RootFolderNotifier rootFolder;
  final MusicHierarchyNotifier hierarchy;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.rootFolder.addListener(_onRootChanged);
    _onRootChanged();
  }

  @override
  void dispose() {
    widget.rootFolder.removeListener(_onRootChanged);
    super.dispose();
  }

  void _onRootChanged() {
    final root = widget.rootFolder.rootFolder;
    if (root != null) {
      widget.hierarchy.rescan(root);
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
