# دليل الحصول على APK

## الطريقة الأولى: GitHub Actions (الأسهل)

### الخطوة 1: تثبيت Git
```bash
# حمّل Git من: https://git-scm.com
# ثبته وأعد تشغيل الكمبيوتر
```

### الخطوة 2: إنشاء مخزن على GitHub
1. افتح https://github.com/new
2. اكتب اسم للمخزن: `secret-recorder`
3. اضغط **Create repository**
4. انسخ الرابط (URL)

### الخطوة 3: رفع المشروع
```bash
# افتح Command Prompt في مجلد المشروع
cd C:\Users\FALCON\Documents\Default Project\secret_recorder_flutter

# شغّل هذا الملف
push_to_github.bat
```

### الخطوة 4: الانتظار
1. افتح مخزنك على GitHub
2. اذهب لتبويب **Actions**
3. سترى عملية البناء جارية
4. بعد الانتهاء، اذهب لتبويب **Releases**
5. حمّل ملف APK من هناك

---

## الطريقة الثانية: Android Studio

### الخطوة 1: تثبيت Android Studio
```bash
# حمّل من: https://developer.android.com/studio
# ثبته وأعد تشغيل الكمبيوتر
```

### الخطوة 2: تثبيت Flutter Plugin
1. افتح Android Studio
2. اذهب لـ **File > Settings > Plugins**
3. ابحث عن **Flutter**
4. اضغط **Install**
5. أعد تشغيل Android Studio

### الخطوة 3: فتح المشروع
1. **File > Open**
2. اختر مجلد المشروع
3. انتظر اكتمال التحميل

### الخطوة 4: بناء APK
1. اذهب لـ **Terminal** في Android Studio
2. اكتب:
```bash
flutter pub get
flutter build apk --release
```
3. الـ APK سيكون في:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## الكود الافتراضي
| الكود | الوظيفة |
|-------|---------|
| `*#0#*` | بدء تسجيل الصوت |
| `#*25#*` | إيقاف تسجيل الصوت |
| `*#00#*` | بدء تسجيل الفيديو |
| `#*26#*` | إيقاف تسجيل الفيديو |
