import "dart:async";
import 'dart:convert';

import "package:flutter/services.dart";
import 'package:password_credential/entity/password_credential.dart';

import "entity/mediation.dart";

/// Credential Management API Access
class Credentials {
  static const MethodChannel _channel =
      const MethodChannel("password_credential");

  /// Weather this platform has PasswordCredential Feature.
  Future<bool> get hasCredentialFeature async {
    return await _channel.invokeMethod("hasCredentialFeature");
  }

  /// get Password Credential
  ///
  /// mediation: if null, default is Mediation.Silent
  /// return: a PasswordCredential, or null if cannot get single Password from Credential Store
  Future<PasswordCredential> get(Mediation mediation) async {
    String result = await _channel.invokeMethod("get",
        <String, dynamic>{"mediation": (mediation ?? Mediation.Silent).string});
    PasswordCredential credential;
    if (result != null) {
      credential = PasswordCredential.fromJson(jsonDecode(result));
    }
    return credential;
  }

  /// store Password Credential
  ///
  /// mediation: if null, default is Mediation.Optional. This is ignored in Web.
  /// return: true if storing is succeeded
  Future<bool> store(PasswordCredential credential, Mediation mediation) async {
    return await _channel.invokeMethod("store", <String, dynamic>{
      "credential": jsonEncode(credential),
      "mediation": (mediation ?? Mediation.Optional).string
    });
  }

  /// clear password for an id
  ///
  /// Web: Overwrite Credential with Empty Password
  /// Android: Delete Credential
  Future<void> delete(String id) async {
    return await _channel.invokeMethod("delete", <String, dynamic>{"id": id});
  }

  /// Disable Silent Access to Current Credential
  Future<void> preventSilentAccess() async {
    return await _channel.invokeMethod("preventSilentAccess");
  }
}
