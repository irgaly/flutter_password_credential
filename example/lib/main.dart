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
              home: Scaffold(body: () {
                void snackbar(String message) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }

                return SafeArea(
                    child: Column(children: [
                  Column(children: [
                    Row(
                      children: [
                        Container(width: 80, child: Text("ID")),
                        Expanded(
                            child: Container(
                                child: TextField(controller: model.idEdit),
                                margin: EdgeInsets.only(right: 20))),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 80, child: Text("Password")),
                        Expanded(
                            child: Container(
                                child:
                                    TextField(controller: model.passwordEdit),
                                margin: EdgeInsets.only(right: 20))),
                      ],
                    ),
                  ]),
                  Expanded(
                      child: ListView(children: <Widget>[
                    ListTile(
                      title: Text("Store(Silent)"),
                      onTap: () {
                        var result = model.store(Mediation.Silent);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Store(Optional)"),
                      onTap: () {
                        var result = model.get(Mediation.Optional);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Store(Required)"),
                      onTap: () {
                        var result = model.get(Mediation.Required);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Get(Silent)"),
                      onTap: () {
                        var result = model.get(Mediation.Silent);
                        snackbar(result.toString());
                      },
                    ),
                    ListTile(
                      title: Text("Get(Optional)"),
                      onTap: () {
                        model.delete();
                        snackbar("Done");
                      },
                    ),
                    ListTile(
                      title: Text("Get(Required)"),
                      onTap: () {
                        model.delete();
                        snackbar("Done");
                      },
                    ),
                    ListTile(
                      title: Text("Delete"),
                      onTap: () {
                        model.delete();
                        snackbar("Done");
                      },
                    ),
                    ListTile(
                      title: Text("hasCredentialFeature"),
                      subtitle: Text(model.hasCredentialFeature.toString()),
                    ),
                    ListTile(
                      title: Text("preventSilentAccess"),
                      onTap: () {
                        model.preventSilentAccess();
                        snackbar("Done");
                      },
                    ),
                    ListTile(
                      title: Text("openPlatformCredentialSettings"),
                      onTap: () {
                        model.openPlatformCredentialSettings();
                        snackbar("Done");
                      },
                    ),
                  ]))
                ]));
              }()));
        }));
  }
}
