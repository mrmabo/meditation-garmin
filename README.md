# Meditation Garmin

A calm meditation timer for iPhone designed to pair with a Garmin Connect IQ companion app.

## Current MVP

- Native SwiftUI meditation timer
- Presets: 5, 10, 15, 20, 30, 45, 60 minutes
- Gentle / Double / Progressive ending patterns
- Pause, resume, stop, and foreground recovery
- Local iPhone haptic fallback while the app is active
- Garmin communication abstraction and command payloads
- No alarm-style sound

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

The timer stores an absolute `endAt` date rather than relying on a decrementing counter. This avoids timer drift when UI updates are throttled.

## Run the iOS app

The repository uses XcodeGen so the generated Xcode project does not need to be committed.

```bash
brew install xcodegen
cd ios
xcodegen generate
open MeditationGarmin.xcodeproj
```

Then select your Apple development team under **Signing & Capabilities** and run on an iPhone with iOS 17+.

## Garmin integration contract

`GarminBridge` defines the app-side protocol. `MockGarminBridge` keeps the iOS project buildable before Garmin's proprietary Connect IQ Mobile SDK is added.

When the SDK is installed, `ConnectIQGarminBridge.swift` is the integration seam. A start command is represented as:

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

### Important reliability rule

The Garmin watch app must own its timer after receiving `start`. iOS can suspend a foreground app after the phone locks, so the phone should not be responsible for sending the final vibration at exactly 20:00. Once started, the watch can finish the session even through a temporary Bluetooth disconnect.

The current iPhone haptic is therefore a development fallback, not the final background reminder mechanism.

## Next milestone

Add the Connect IQ device app under `garmin/`, implement the gentle vibration patterns on-device, and bind Garmin's official iOS Connect IQ Mobile SDK to `GarminBridge`.
