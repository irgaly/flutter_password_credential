-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.SerializationKt
-keep,includedescriptorclasses class net.irgaly.password_credential.**$$serializer { *; }
-keepclassmembers class net.irgaly.password_credential.** {
    *** Companion;
}
-keepclasseswithmembers class net.irgaly.password_credential.** {
    kotlinx.serialization.KSerializer serializer(...);
}
