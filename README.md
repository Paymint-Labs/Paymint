# Paymint
NOTE: Paymint is currently in VERY EARLY alpha stage. Expected release is in q2-q3 2020.

Paymint is a Bitcoin thin client written in Dart. Out of the box, it aims to be an HD wallet with support for Native Segwit addresses, full UTXO selection controls and payment batching.

## Build and run
- Flutter version v1.12.13+hotfix.8 required
- Android/iOS dev setup (Android Studio, xCode and subsequent dependencies)
- Navigate into project root and run the following:
```
flutter doctor
flutter pub get
flutter run --release
```

## Features
- HD Native Segwit Addresses (BIP 84, 173)
- Advanced UTXO selection/filtering
- Payment Batching
- Cloud wallet backups
- Shamir's Secret Sharing Private Key Splitting [COMING SOON]

## Screenshots
<img src="https://imgur.com/ib2IPoP.jpg" width="400" align="left"> <img src="https://imgur.com/hJQmhkw.jpg" width="400" align="right">
