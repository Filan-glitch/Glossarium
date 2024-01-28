import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:glossarium/pages/glossar_list_page.dart';
import 'package:glossarium/pages/glossar_page.dart';
import 'package:glossarium/redux/state.dart';
import 'package:glossarium/redux/store.dart';
import 'package:glossarium/storage/database.dart';
import 'package:glossarium/storage/firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders(
    [GoogleProvider(clientId: '511119835118-69ng32k7lag19ue1vcgj3rn7go5lehsh.apps.googleusercontent.com'),]
  );

  await loadGlossarys();
  await loadGlossaryEntrys();
  await loadSyncGlossarys();

  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          title: 'Glossarium',
          themeMode: ThemeMode.system,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          supportedLocales: const [
            Locale('de', 'DE'),
            Locale('us', 'US'),
          ],
          localizationsDelegates:
              const [
                // ... app-specific localization delegate[s] here
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
          initialRoute: FirebaseAuth.instance.currentUser == null ? '/' : '/glossar-list',
          routes: {
            '/': (context) {
              return SignInScreen(
                actions: [
                  AuthStateChangeAction(
                  (context, state) {
                      if(state is UserCreated || state is SignedIn) {
                        var user = (state is SignedIn)
                            ? state.user
                            : (state as UserCreated).credential.user;
                        if (user == null) return;
                        if (state is UserCreated && user.displayName == null && user.email != null) {
                          var defaultDisplayName = user.email!.split('@')[0];
                          user.updateDisplayName(defaultDisplayName);
                        }
                        Navigator.of(context).pushReplacementNamed(
                            '/glossar-list',
                        );
                      }
                    }
                  )
                ],
              );
            },
            '/glossar-list': (context) => const GlossarListPage(),
            '/glossar': (context) => const GlossarPage(),
          },
        ),
    );
  }
}