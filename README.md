# NOTE: This project has been deprecated for a while now, I no longer maintain the application. I'm leaving the source code up for anyone who is still interested

# Paymint - A secure bitcoin wallet
Paymint is a Bitcoin thin client written in Dart with powerful features.

[![Playstore](https://bluewallet.io/img/play-store-badge.svg)](https://play.google.com/store/apps/details?id=com.paymintlabs.paymint)

## Feature List
✅ Basic fee selection controls

✅ Coin Control
- UTXO renaming (labeling)
- Block/Unblock UTXOs
- Export Ouput data to CSV
- Restore Output labels and block status from CSV import
 
✅ View transaction worth in fiat when sent/received to the wallet AND current worth

✅ Export transaction data to CSV

✅ Preview transaction before sending
- View amount being sent + fee in BTC, sats, or fiat currency

✅ Custom Esplora-Electrs server support

✅ 15 Currencies supported

✅ Native Segwit by default

✅ And many more...

## Build and run
### Prerequisites
- Flutter SDK Requirement (>=2.2.0, up until <3.0.0)
- Android/iOS dev setup (Android Studio, xCode and subsequent dependencies)
- Navigate into project root and run the following:

Plug in your android device or use the emulator available via Android Studio and then run the following commands from project root:
```
flutter pub get
flutter run --release
```

## Screenshots
<img src="https://i.imgur.com/wwFTog5.jpg" width="250"> <img src="https://i.imgur.com/S7hJvfu.jpg" width="250"> <img src="https://i.imgur.com/aUPmgEq.jpg" width="250">

<img src="https://i.imgur.com/A94PyL4.jpg" width="250"> <img src="https://i.imgur.com/D602Htc.jpg" width="250">
