# Secret Recorder Flutter

## مسجل سري - Flutter Version

### المتطلبات
- Flutter SDK >= 3.0.0
- Android SDK >= 26
- Android Studio

### خطوات البناء

#### 1. تثبيت Flutter
```bash
# تحميل Flutter من:
# https://docs.flutter.dev/get-started/install

# بعد التثبيت، تحقق من التثبيت:
flutter doctor
```

#### 2. فتح المشروع
```bash
cd secret_recorder_flutter
flutter pub get
```

#### 3. تشغيل التطبيق
```bash
# تشغيل على جهاز متصل
flutter run

# بناء APK
flutter build apk --release
```

#### 4. موقع الـ APK
```
build/app/outputs/flutter-apk/app-release.apk
```

### الكود الافتراضي للتسجيل
- بدء الصوت: `*#0#*`
- إيقاف الصوت: `#*25#*`
- بدء الفيديو: `*#00#*`
- إيقاف الفيديو: `#*26#*`

### تغيير الأكواد
من شاشة Settings داخل التطبيق يمكنك تغيير أي كود

### الميزات
- تسجيل صوت سري عبر أكواد الاتصال
- تسجيل فيديو سري
- تشفير AES-256-GCM لجميع الملفات
- مشغل داخلي آمن
- واجهة مستخدم داكنة
- إعدادات قابلة للتخصيص
