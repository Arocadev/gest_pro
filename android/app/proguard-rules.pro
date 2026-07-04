-keep class com.dexterous.** { *; }
-keep class androidx.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class **.R
-keep class **.R$* {
    <fields>;
}