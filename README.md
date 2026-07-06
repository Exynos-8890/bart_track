# Bart Track

Minimal macOS WidgetKit project code for tracking BART departures from Daly City.

## What It Shows

- Daly City northbound and southbound departures.
- An 8-minute walking buffer from home to station.
- Compact, rectangular, and expanded widget densities.
- The next catchable train in compact layouts.
- The next two trains in rectangular layouts.
- Up to four visible trains per direction in expanded layouts.

## Data Source

The first iteration uses BART's Legacy ETD JSON endpoint:

```text
https://api.bart.gov/api/etd.aspx?cmd=etd&orig=DALY&key=MW9S-E7SL-26DU-VV8V&json=y
```

BART currently points developers toward GTFS and GTFS-RT for standards-based data, but the ETD endpoint is the smallest reliable starting point for station departure countdowns. The code keeps the request and decoding logic isolated so the backend can be swapped to GTFS-RT later without rewriting the widget UI.

## Structure

```text
Sources/BartTrackCore
  BART request, live data service, ETD decoding, departure board rules.

Sources/BartTrackWidgetUI
  SwiftUI widget surfaces and size-specific presentation rules.

Sources/BartTrackWidgetKit
  WidgetKit timeline provider, refresh policy, and widget definition.

App/BartTrackWidgetExtension
  Minimal @main entry point for a real Xcode Widget Extension target.
```

## Verify

```bash
swift test
```

The test suite covers decoding, service URL usage, 8-minute catchability, presentation density, and WidgetKit family mapping.

## Git Checkpoints

Each major step is committed separately:

```bash
git log --oneline
```

Rollback examples:

```bash
git revert HEAD
git revert <commit-sha>
```

## Xcode Integration

For the minimal installable macOS widget:

1. Create a macOS App project in Xcode.
2. Add a Widget Extension target.
3. Add this repository as a local Swift package dependency.
4. Link `BartTrackWidgetKit` to the Widget Extension target.
5. Replace the generated widget bundle file with `App/BartTrackWidgetExtension/BartTrackWidgetBundle.swift`.
6. Ensure the Widget Extension has outbound network access enabled by the host app's sandbox settings if sandboxing is turned on.

WidgetKit controls the exact refresh schedule. This project requests a refresh every 60 seconds through the timeline policy, but macOS may defer updates based on system policy.
