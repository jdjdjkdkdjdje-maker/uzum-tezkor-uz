# Uzum Tezkor — Mijoz mobil ilovasi (Flutter)

`uzum-tezkor-backend` API'siga ulanadigan, Android va iOS uchun mijoz ilovasi.

## Dizayn

- **Ranglar:** iliq krem fon (`#FFFBF5`) + pomidor-qizil urg'u (`#E4572E`) — ishtaha
  uyg'otuvchi, admin/restoran panellaridan mustaqil, alohida uslub
- **Shrift:** sarlavhalar uchun Sora, matn uchun Plus Jakarta Sans (Google Fonts)
- **Oqim:** Splash → Telefon+OTP/Google/Apple → Bosh sahifa → Restoran → Taom → Savatcha
  → Checkout → Buyurtma kuzatuvi

## Ishga tushirish

Bu papkada faqat `lib/` va `pubspec.yaml` bor — Android/iOS platforma fayllarini
Flutter SDK generatsiya qilishi kerak:

```bash
# 1) Yangi Flutter loyihasi yarating (platforma fayllari uchun)
flutter create --org uz.uzumtezkor uzum_tezkor_customer_app
cd uzum_tezkor_customer_app

# 2) Ushbu arxivdagi lib/ va pubspec.yaml bilan almashtiring
rm -rf lib pubspec.yaml
cp -r /path/to/this/lib .
cp /path/to/this/pubspec.yaml .

# 3) Paketlarni o'rnating
flutter pub get

# 4) Backend manzilini ko'rsatib ishga tushiring
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

`10.0.2.2` — Android emulyatordan kompyuter `localhost`iga murojaat qilish manzili.
Haqiqiy qurilmada backendning tarmoqdagi IP manzilini yoki production domenini bering.

## Talab qilinadigan qo'shimcha sozlashlar

- **Firebase**: `flutterfire configure` orqali `firebase_options.dart` generatsiya qiling
  (push notification uchun)
- **Google Sign-In**: Firebase/Google Cloud Console'da OAuth client ID sozlang
- **Apple Sign-In**: Apple Developer'da Sign in with Apple capability yoqing (faqat iOS)
- **Google Maps**: `android/app/src/main/AndroidManifest.xml` va iOS `AppDelegate.swift`
  ga Google Maps API key qo'shing

## Tuzilma

```
lib/
├── main.dart, app.dart
├── core/
│   ├── theme/            # Ranglar, shriftlar, ThemeData
│   ├── network/           # Dio API mijozi, xatoliklar
│   ├── storage/            # Xavfsiz token saqlash
│   ├── models/              # User, Restaurant, Product, Order, Cart, Address...
│   ├── repositories/         # Backend bilan ishlaydigan API qatlami
│   └── utils/                 # Narx/sana formatlash
├── state/                # Provider: Auth, Cart, Location
├── widgets/                # Umumiy vidjetlar (CartBar, QuantityStepper...)
└── features/
    ├── auth/          # Splash, telefon+OTP, ijtimoiy kirish
    ├── home/           # Bosh sahifa: banner, kategoriya, restoranlar
    ├── restaurant/      # Restoran tafsilotlari va menyu
    ├── product/          # Taom tafsilotlari (variant/qo'shimcha)
    ├── cart/               # Savatcha
    ├── checkout/            # Buyurtmani rasmiylashtirish
    ├── orders/                # Buyurtma kuzatuvi va tarixi
    └── profile/                # Profil va sozlamalar
```

## Eslatma

Ilova hozircha real-time kuryer kuzatuvi uchun **so'rov (polling)** ishlatadi
(`order_tracking_screen.dart`, har 10 soniyada). Backendda tayyor bo'lgan Socket.IO
(`realtime.gateway.ts`) bilan ulash uchun `socket_io_client` paketi allaqachon
`pubspec.yaml`ga qo'shilgan — buni ulash keyingi bosqichda amalga oshirilishi mumkin.
