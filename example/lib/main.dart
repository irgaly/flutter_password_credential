import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider<Model>(create: (_) => Model())],
        child: Consumer<Model>(builder: (context, model, _) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                  body: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Google Login"),
                  ),
                  ListTile(
                    title: Text("Logout"),
                  ),
                  ListTile(
                    title: Text("hasCredentialFeature"),
                    subtitle: Text(model.hasCredentialFeature),
                  ),
                ],
              )));
        }));
  }
}
