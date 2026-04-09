# Mixcine Movie App

Flutter movie app demo built with Dart, Riverpod, and a simple clean architecture folder structure.

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

---
 *If you need help or any further contact please contact through my Gmail which locate on my Github profile, wishing you have a nice day.* 

## Notes

- This is still in the beta version of developing so expecting bugs and non-functional button.
- Remember to update Flutter and Dart to the latest version to make sure everything works.
- This repo was created in 9th April 2026, as University final project by the team of 5
