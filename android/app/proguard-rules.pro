# Keep all Android window classes
-keep class android.window.** { *; }
-dontwarn android.window.**

# Keep Flutter-specific classes
-keep class io.flutter.** { *; }

# Keep classes for flutter_inappwebview
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# Don't warn about missing BackEvent
-dontwarn android.window.BackEvent