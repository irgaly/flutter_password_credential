import "dart:async";
import "dart:html" as html;
import "dart:js";

import "package:flutter/services.dart";
import "package:flutter_web_plugins/flutter_web_plugins.dart";
import "package:password_credential/entity/mediation.dart";
import "package:password_credential/entity/password_credential.dart";

class PasswordCredentialPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel("password_credential",
        const StandardMethodCodec(), registrar.messenger);
    channel.setMethodCallHandler(PasswordCredentialPlugin().handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "hasCredentialFeature":
        return await _hasCredentialFeature();
      case "get":
        final Mediation mediation =
            call.arguments["mediation"] ?? Mediation.Silent;
        return await _get(mediation);
      case "store":
        final PasswordCredential credential = call.arguments["credential"];
        if (credential == null) {
          throw ArgumentError("credential is null");
        }
        return await _store(credential);
      case "delete":
        final String id = call.arguments["id"];
        if (id == null) {
          throw ArgumentError("id is null");
        }
        return await _delete(id);
      case "preventSilentAccess":
        return await _preventSilentAccess();
      default:
        throw PlatformException(
            code: "Unimplemented",
            details: "The password_credential plugin for web doesn't implement "
                "the method \"${call.method}\"");
    }
  }

  Future<bool> _hasCredentialFeature() async {
    return context.hasProperty("PasswordCredential");
  }

  Future<PasswordCredential> _get(Mediation mediation) async {
    html.Credential c = await html.window.navigator.credentials
        .get({"password": true, "mediation": _getMediation(mediation)});
    if (c is html.PasswordCredential) {
      return PasswordCredential(
          id: c.id, password: c.password, name: c.name, iconUrl: c.iconUrl);
    }
    return null;
  }

  Future<void> _store(PasswordCredential credential) async {
    var credentials = html.window.navigator.credentials;
    var c = await credentials.create({
      "password": {
        "id": credential.id,
        "password": credential.password,
        "name": credential.name,
        "iconUrl": credential.iconUrl
      }
    });
    await credentials.store(c);
  }

  Future<void> _delete(String id) async {
    var credentials = html.window.navigator.credentials;
    var c = await credentials.create({
      "password": {"id": id, "password": ""}
    });
    await credentials.store(c);
  }

  Future<void> _preventSilentAccess() async {
    return await html.window.navigator.credentials.preventSilentAccess();
  }

  String _getMediation(Mediation mediation) {
    switch (mediation) {
      case Mediation.Silent:
        return "silent";
      case Mediation.Optional:
        return "optional";
      case Mediation.Required:
        return "required";
    }
  }
}
