import 'package:flutter/material.dart';
import 'package:password_credential/entity/mediation.dart';
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
              home: Scaffold(body: Builder(builder: (context) {
                void snackbar(String message) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }

                return SafeArea(
                    child: Column(children: [
                  Container(
                      child: Column(children: [
                        Row(
                          children: [
                            Container(width: 80, child: Text("ID")),
                            Expanded(child: TextField(controller: model.idEdit))
                          ],
                        ),
                        Row(
                          children: [
                            Container(width: 80, child: Text("Password")),
                            Expanded(
                                child:
                                    TextField(controller: model.passwordEdit))
                          ],
                        ),
                      ]),
                      margin: EdgeInsets.only(left: 20, right: 20)),
                  Expanded(
                      child: ListView(children: <Widget>[
                    ListTile(
                      title: Text("Store(Silent)"),
                      onTap: () async {
                        try {
                          var result = await model.store(Mediation.Silent);
                          snackbar(result.toString());
                        } catch (e) {
                          snackbar(e.toString());
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Store(Optional)"),
                      onTap: () async {
                        try {
                          var result = await model.store(Mediation.Optional);
                          snackbar(result.toString());
                        } catch (e) {
                          snackbar(e.toString());
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Store(Required)"),
                      onTap: () async {
                        try {
                          var result = await model.store(Mediation.Required);
                          snackbar(result.toString());
                        } catch (e) {
                          snackbar(e.toString());
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Get(Silent)"),
                      onTap: () async {
                        var result = await model.get(Mediation.Silent);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Get(Optional)"),
                      onTap: () async {
                        var result = await model.get(Mediation.Optional);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Get(Required)"),
                      onTap: () async {
                        var result = await model.get(Mediation.Required);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Delete"),
                      onTap: () async {
                        try {
                          await model.delete();
                          snackbar("Done");
                        } catch (e) {
                          snackbar(e.toString());
                        }
                      },
                    ),
                    ListTile(
                      title: Text("hasCredentialFeature"),
                      subtitle: Text(model.hasCredentialFeature.toString()),
                    ),
                    ListTile(
                      title: Text("preventSilentAccess"),
                      onTap: () async {
                        await model.preventSilentAccess();
                        snackbar("Done");
                      },
                    ),
                    ListTile(
                      title: Text("openPlatformCredentialSettings"),
                      onTap: () async {
                        await model.openPlatformCredentialSettings();
                        snackbar("Done");
                      },
                    ),
                  ]))
                ]));
              })));
        }));
  }
}
