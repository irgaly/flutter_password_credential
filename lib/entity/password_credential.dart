import 'package:flutter/foundation.dart';

/// Password Credential
@immutable
class PasswordCredential {
  final String? id;
  final String? password;
  final String? name;
  final String? iconUrl;

  PasswordCredential(
      {required this.id, required this.password, this.name, this.iconUrl});

  factory PasswordCredential.fromJson(Map<String, dynamic> json) {
    return PasswordCredential(
        id: json["id"],
        password: json["password"],
        name: json["name"],
        iconUrl: json["iconUrl"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "password": password, "name": name, "iconUrl": iconUrl};
  }

  @override
  String toString() {
    return 'PasswordCredential{id: $id, password: $password, name: $name, iconUrl: $iconUrl}';
  }
}
