# TrainQuest Flutter App

This Flutter app is now integrated with the Flask backend in `../../../trainquest_backend_a`.

## iPhone Setup Guide

For teammate setup on a Mac and deployment to a real iPhone, see:

- `docs/ios_teammate_setup.md`

## What Is Connected

- Login and register
- Home dashboard
- Daily and project tasks
- Today progress updates
- Daily sign-in
- Workout photo upload
- Badge and level display
- User profile and logout

## Backend Setup

From `trainquest_backend_a`:

```bash
pip install -r requirements.txt
python app.py
```

The Flask server runs on:

```text
http://127.0.0.1:5000
```

## Flutter Setup

From this Flutter project directory:

```bash
flutter pub get
flutter run
```

## API Base URL

The app reads the backend URL from the compile-time variable:

```bash
--dart-define=TRAINQUEST_API_BASE_URL=http://127.0.0.1:5000
```

Example:

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://127.0.0.1:5000
```

If you run on an Android emulator, the default URL is already set to:

```text
http://10.0.2.2:5000
```

If you run on a real phone, replace the URL with your computer's LAN IP, for example:

```bash
flutter run --dart-define=TRAINQUEST_API_BASE_URL=http://192.168.1.8:5000
```

## Notes

- The backend must be running before the Flutter app logs in.
- Uploaded photos are stored by the Flask backend in `trainquest_backend_a/uploads/`.
- Session state is stored locally with `shared_preferences`.
