# WhatsApp-style Firebase App

This folder contains a Flutter app inspired by WhatsApp, with:
- Firebase Authentication
- Firestore-based messaging
- Login / signup flow
- Contact list screen
- Chat screen with real-time updates

Setup:
1. Open Firebase console and create a project.
2. Enable Authentication > Email/Password.
3. Enable Firestore.
4. Run:
   ```bash
   flutterfire configure
   ```
5. Then run:
   ```bash
   flutter pub get
   flutter run
   ```

Note:
- Replace the placeholder values in `lib/firebase_options.dart` if FlutterFire configuration is not used.
