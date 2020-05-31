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

  factory PasswordCredential.fromMap(Map<String, dynamic> map) {
    return PasswordCredential(
        id: map["id"],
        password: map["password"],
        name: map["name"],
        iconUrl: map["iconUrl"]);
  }

  Map<String, dynamic> toMap() {
    return {"id": name, "password": password, "name": name, "iconUrl": iconUrl};
  }
}
