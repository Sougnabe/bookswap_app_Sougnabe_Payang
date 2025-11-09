# Firebase Setup Instructions

## 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `bookswap-app`
4. Disable Google Analytics (optional)
5. Click "Create project"

## 2. Android Configuration
1. In Firebase console, click Android icon
2. Android package name: `com.example.bookswapapp`
3. App nickname: `BookSwap App`
4. Download `google-services.json`
5. Place it in `android/app/` directory

## 3. iOS Configuration (if needed)
1. In Firebase console, click iOS icon
2. iOS bundle ID: `com.example.bookswapApp`
3. App nickname: `BookSwap App`
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

## 4. Enable Authentication
1. In Firebase console, go to Authentication
2. Click "Get started"
3. Go to Sign-in method tab
4. Enable "Email/Password"

## 5. Setup Firestore Database
1. In Firebase console, go to Firestore Database
2. Click "Create database"
3. Start in test mode
4. Choose location closest to your users

## 6. Update Firebase Options
Update `lib/firebase_options.dart` with your actual Firebase config values from the downloaded config files.