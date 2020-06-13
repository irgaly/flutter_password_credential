import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:password_credential/credentials.dart';
import 'package:password_credential/entity/mediation.dart';
import 'package:password_credential/entity/password_credential.dart';
import 'package:password_credential/entity/result.dart';

class Model with ChangeNotifier {
  final _credentials = Credentials();

  bool hasCredentialFeature = false;
  var idEdit = TextEditingController();
  var passwordEdit = TextEditingController();

  Model() {
    Future(() async {
      hasCredentialFeature = await _credentials.hasCredentialFeature;
      notifyListeners();
    });
  }

  Future<Result> store(Mediation mediation) async {
    return await _credentials.store(idEdit.text, passwordEdit.text, mediation);
  }

  Future<PasswordCredential> get(Mediation mediation) async {
    var credential = await _credentials.get(mediation);
    if (credential != null) {
      idEdit.text = credential.id;
      passwordEdit.text = credential.password;
      notifyListeners();
    }
    return credential;
  }

  Future<void> delete() async {
    await _credentials.delete(idEdit.text);
  }

  Future<void> preventSilentAccess() async {
    await _credentials.preventSilentAccess();
  }

  Future<void> openPlatformCredentialSettings() async {
    await _credentials.openPlatformCredentialSettings();
  }
}
