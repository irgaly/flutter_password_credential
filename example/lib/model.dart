import 'package:flutter/foundation.dart';
import 'package:password_credential/credentials.dart';

class Model with ChangeNotifier {
  final _credentials = Credentials();

  String hasCredentialFeature = "";

  Model() {
    Future(() async {
      hasCredentialFeature =
          (await _credentials.hasCredentialFeature).toString();
      notifyListeners();
    });
  }
}
