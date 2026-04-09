# Mixcine Movie App

Flutter movie app demo built with Dart, Riverpod, and a simple clean architecture folder structure.

## What I changed in this revision

- Kept the app branding as **Mixcine**
- Moved the app name into one file: `lib/core/config/app_branding.dart`
- Moved TMDB connection values into a separate local file: `lib/core/config/api_config.dart`
- Added `lib/core/config/api_config.example.dart` as a template
- Added `.gitignore` so `api_config.dart` is not pushed to GitHub by accident
- Updated the dark theme colors to be closer to the noir / red reference

## Included screens

- Splash screen
- Onboarding screen
- Home screen
- Movie detail screen
- Search screen
- Favorites screen
- Profile screen
- Video player screen

## Tech stack

- Flutter + Dart
- Riverpod
- go_router
- dio
- cached_network_image
- video_player
- shared_preferences

## Project structure

```text
lib/
  core/
    config/
    routing/
    services/
    theme/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    screens/
    widgets/
```

## Run the project

1. Install Flutter stable.
2. Open the project.
3. Run `flutter pub get`
4. Run `flutter run`

## Use mock data or TMDB

The project still uses mock data by default.

### Mock mode

- Open `lib/core/config/app_config.dart`
- Keep `useMockData = true`

### API mode

1. Open `lib/core/config/app_config.dart`
2. Change `useMockData = false`
3. Open `lib/core/config/api_config.dart`
4. Paste your API key into `tmdbApiKey`
5. Run the app again


## Notes

- The layout is still a developer-friendly base so your team can continue adjusting it screen by screen.
