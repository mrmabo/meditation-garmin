# Meditation Garmin

A calm meditation timer for iPhone designed to pair with a Garmin Connect IQ companion app.

## MVP

- SwiftUI meditation timer
- Presets: 5, 10, 15, 20, 30, 45, 60 minutes
- Gentle / Double / Progressive ending patterns
- Local iPhone haptic fallback
- Garmin communication abstraction
- Session state that survives normal app lifecycle changes
- No alarm-style sound by default

## Architecture

```
iOS (SwiftUI)
  MeditationView
       |
  MeditationViewModel
       |
  MeditationSession
       |
  ReminderService ---- GarminBridge
       |                   |
 iPhone haptics       Connect IQ adapter
```

The timer is represented by an absolute end date rather than decrementing a counter. This avoids timer drift when iOS throttles UI updates.

## Run the iOS app

1. Open `ios/MeditationGarmin.xcodeproj` in Xcode.
2. Select your development team under Signing & Capabilities.
3. Run on iOS 17+.

The project has no third-party dependency for the local MVP.

## Garmin integration

`GarminBridge` defines the app-side protocol. `MockGarminBridge` keeps the project runnable before the proprietary Garmin Connect IQ Mobile SDK is added.

When the Garmin SDK is installed, implement `ConnectIQGarminBridge` and send this payload to the watch app:

```json
{
  "type": "start",
  "sessionId": "UUID",
  "durationSeconds": 1200,
  "pattern": "progressive",
  "startedAt": 178... 
}
```

Commands: `start`, `pause`, `resume`, `stop`.

The watch should own its timer after receiving `start`; the phone should not need to stay awake or connected.

## Next step

Add the Connect IQ watch app under `garmin/`, then bind the official iOS Connect IQ Mobile SDK in `ConnectIQGarminBridge`.
