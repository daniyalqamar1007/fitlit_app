# Flutter-specific ProGuard rules for release builds

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Dart VM classes
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep platform channel classes
-keep class io.flutter.plugins.** { *; }

# Keep JSON serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep model classes (adjust package names as needed)
-keep class com.yourpackage.model.** { *; }

# Dio and network related
-keep class com.dio.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Image processing
-keep class com.bumptech.glide.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# File operations
-keep class io.flutter.plugins.pathprovider.** { *; }

# ReadyPlayer.me related (if using specific SDKs)
-keep class me.readyplayer.** { *; }

# Preserve source file line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Flutter specific optimizations
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimize for performance
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''