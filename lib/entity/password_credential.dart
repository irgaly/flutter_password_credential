import 'package:flutter/foundation.dart';

/// Password Credential
@immutable
class PasswordCredential {
  final String id;
  final String password;
  final String name;
  final String iconUrl;

  PasswordCredential(
      {@required this.id, @required this.password, this.name, this.iconUrl});
}
