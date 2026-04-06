# Moneyboy iOS

Native iOS 26 SwiftUI app for personal finance tracking. Uses the same Firebase backend as the Moneyboy PWA.

## Requirements

- Xcode 26+
- iOS 26+ deployment target
- Firebase project (same as PWA: `moneyboy-2f088`)

## Setup

1. Clone the repo
2. Add `GoogleService-Info.plist` to `Moneyboy/` (download from Firebase Console)
3. Open `Moneyboy.xcodeproj` in Xcode
4. Add Firebase iOS SDK via SPM: `https://github.com/firebase/firebase-ios-sdk`
   - Products: FirebaseAuth, FirebaseFirestore, FirebaseMessaging
5. Build & run

## Architecture

- **Models**: `FinanceItem`, `ScenarioData`, `FinanceSummary` — match PWA Firestore schema exactly
- **Services**: `AuthService`, `FirestoreService`, `ScenarioService`, `NotificationService`
- **ViewModels**: `AppViewModel`, `WhatIfViewModel`, `SettingsViewModel`
- **Views**: SwiftUI views using iOS 26 Liquid Glass (`.glassEffect()`)

## Firestore Paths

Same paths as PWA:
```
users/{uid}/items/{itemId}          — FinanceItem documents
users/{uid}/scenarios/whatif        — ScenarioData document
users/{uid}/fcmTokens/{token}       — FCM token documents
```
