# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.firebase.** { *; }

# Multidex
-keep class androidx.multidex.** { *; }

# Keep R
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Keep FCM classes
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebasemessaging.** { *; }

# Keep notification-related classes
-keep class com.dexterous.** { *; }

# Keep entry points
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Flutter Local Notifications specific rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.core.content.** { *; }

# Keep callback methods that are annotated with @pragma('vm:entry-point')
-keep class * {
    @androidx.annotation.Keep <methods>;
    @androidx.annotation.Keep <fields>;
    @dart.pragma.vm.entry-point <methods>;
}

# Keep notification-related classes
-keep class android.app.Notification** { *; }
-keep class android.app.NotificationChannel** { *; }
-keep class android.app.NotificationManager** { *; }

