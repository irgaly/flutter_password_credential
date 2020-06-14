# password_credential

Flutter Plugin for Password Credentials Access.

* Web (Chrome): Credentials Management API
    * [Chrome Credentials Management Document](https://developers.google.com/web/fundamentals/security/credential-management/retrieve-credentials?hl=en)
* Android: Smartlock for Password
    * [Android Smartlock for Password Document](https://developer.android.com/distribute/best-practices/develop/smart-lock-for-passwords)

ID and Passwords stored in Credential Management API or Smartlock are synced when user logged in Chrome or Android with same Google Account.

## Example Project

Web Example Project.

![web](doc/example_web.png)

Android Example Project.

![android](doc/example_android.png)

## User Settings

Describing User-side Settings for Credentials Management System.

If the user has disabled Password Storing at System wide, or disabled per apps, the storing operations always failed with no user interaction.

If the user has disabled Auto Sign-in at System wide, the Silent Read operation always failed, and other read operation always asking user to read a password entry.

![web](doc/user_settings_web.png)

![android](doc/user_settings_android.png)

