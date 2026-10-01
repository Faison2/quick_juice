# google_mlkit_text_recognition references optional script recognizers
# (Chinese/Japanese/Korean/Devanagari) that we don't depend on since we
# only use the default Latin recognizer. R8 can't resolve them at
# compile time in release builds; they're never invoked at runtime.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
