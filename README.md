# Bart Track

[English](README.md) | [简体中文](README.zh-CN.md)

Bart Track is a macOS desktop widget for viewing real-time BART departure countdowns. It was originally designed around a Daly City commute: when walking to the station takes several minutes, the widget can show only the trains you can realistically catch.

The current version supports:

- Selecting any BART origin station; the default is `Daly City`.
- Setting the walking time to the station; the default is `8` minutes, with a range of `0...60`.
- Choosing whether to show only catchable trains; enabled by default.
- Hiding the main app's Dock icon by default, with an option to show it again.
- Opening BART's official Daly City real-time departures page through `barttrack://open-live-bart` when you click `LIVE BART` in the widget.
- Different information densities for small, medium, large, and extra-large widget families.
- A last-updated time plus `OLD` / `STALE` indicators when WidgetKit does not refresh on time.
- A debug log for diagnosing stale information.

## Display Logic

The numbers in the widget mean **how many minutes remain until a train arrives**, not how many minutes you should wait before leaving home.

The default configuration is:

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

This means:

- `station: "DALY"`: depart from Daly City station.
- `walkingMinutes: 8`: it takes 8 minutes to walk to the station.
- `showsOnlyCatchableDepartures: true`: show only trains arriving in more than 8 minutes.
- `showsDockIcon: false`: hide the main app's Dock icon while it is running.
- `openURLString`: the page opened by the widget's `LIVE BART` button; by default, BART's official Daly City real-time departures page.

For example, a train arriving in `7m` is hidden when the walking time is `8`, because you are unlikely to catch it. A train arriving in `10m` is shown.

Setting `walkingMinutes` to `0` effectively shows all future departures, although `Leaving` / `0m` trains are still not treated as catchable.

## Widget Sizes

Current display density:

- Small / `1x1`: up to 3 catchable trains per direction, with north and south in two columns.
- Medium / `1x2`: up to 4 catchable trains per direction.
- Large / `2x2` and Extra Large: up to 8 catchable trains per direction.

Each departure shows only its minutes and route color. Destinations, platforms, catchable counts, and other space-consuming details are omitted.

## Recommended Setup: Use the App

After installation, open:

```bash
open ~/Applications/BartTrack.app
```

The app window lets you configure:

- `Station`: origin station.
- `Walking time`: minutes required to walk from your current location to the station.
- `Show only later trains`: whether to show only trains arriving after the walking-time threshold.
- `Show Dock icon`: whether the main app appears in the Dock.
- `Open URL`: the page opened by the desktop widget's `LIVE BART` button.

Changes are saved automatically, and the app calls `WidgetCenter.shared.reloadAllTimelines()` to request a widget refresh.

Note that macOS WidgetKit does not guarantee an immediate refresh. It may delay updates according to system conditions, so an occasional `OLD` indicator does not necessarily mean the BART API failed.

You can quit the Bart Track app. Automatic widget refreshes are performed by the Widget extension under macOS WidgetKit and do not require the main app to remain running. The main app only provides settings, writes configuration, requests manual refreshes, and displays the debug log.

## Edit the Configuration File Manually

The configuration file is located at:

```text
~/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/settings.json
```

Open its directory with:

```bash
open "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack"
```

Or open the file directly in a text editor:

```bash
open -e "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/settings.json"
```

Example configuration:

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

Field reference:

| Field | Type | Description |
| --- | --- | --- |
| `station` | string | BART station abbreviation, such as `DALY` for Daly City. |
| `walkingMinutes` | number | Minutes required to reach the station; clamped to `0...60`. |
| `showsOnlyCatchableDepartures` | boolean | `true` shows only trains arriving after the walking-time threshold; `false` keeps trains in the original chronological order. |
| `showsDockIcon` | boolean | `false` hides the main app's Dock icon; `true` shows it. |
| `openURLString` | string | URL opened by `LIVE BART`, such as `https://www.bart.gov/schedules/eta/DALY`. |

After editing the file manually, open Bart Track and click `Reload Widget`, or reopen the app:

```bash
open ~/Applications/BartTrack.app
```

## Common Configuration Examples

Daly City, 8-minute walk, catchable trains only:

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/DALY",
  "station": "DALY",
  "walkingMinutes": 8
}
```

24th St. Mission, 5-minute walk:

```json
{
  "showsOnlyCatchableDepartures": true,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/24TH",
  "station": "24TH",
  "walkingMinutes": 5
}
```

Embarcadero, all future departures:

```json
{
  "showsOnlyCatchableDepartures": false,
  "showsDockIcon": false,
  "openURLString": "https://www.bart.gov/schedules/eta/EMBR",
  "station": "EMBR",
  "walkingMinutes": 0
}
```

## BART Station Abbreviations

The `station` value must use an official BART station abbreviation.

| Abbreviation | Station |
| --- | --- |
| `12TH` | 12th St. Oakland City Center |
| `16TH` | 16th St. Mission |
| `19TH` | 19th St. Oakland |
| `24TH` | 24th St. Mission |
| `ANTC` | Antioch |
| `ASHB` | Ashby |
| `BALB` | Balboa Park |
| `BAYF` | Bay Fair |
| `BERY` | Berryessa/North San Jose |
| `CAST` | Castro Valley |
| `CIVC` | Civic Center/UN Plaza |
| `COLS` | Coliseum |
| `COLM` | Colma |
| `CONC` | Concord |
| `DALY` | Daly City |
| `DBRK` | Downtown Berkeley |
| `DUBL` | Dublin/Pleasanton |
| `DELN` | El Cerrito del Norte |
| `PLZA` | El Cerrito Plaza |
| `EMBR` | Embarcadero |
| `FRMT` | Fremont |
| `FTVL` | Fruitvale |
| `GLEN` | Glen Park |
| `HAYW` | Hayward |
| `LAFY` | Lafayette |
| `LAKE` | Lake Merritt |
| `MCAR` | MacArthur |
| `MLBR` | Millbrae |
| `MLPT` | Milpitas |
| `MONT` | Montgomery St. |
| `NBRK` | North Berkeley |
| `NCON` | North Concord/Martinez |
| `OAKL` | Oakland International Airport |
| `ORIN` | Orinda |
| `PITT` | Pittsburg/Bay Point |
| `PCTR` | Pittsburg Center |
| `PHIL` | Pleasant Hill/Contra Costa Centre |
| `POWL` | Powell St. |
| `RICH` | Richmond |
| `ROCK` | Rockridge |
| `SBRN` | San Bruno |
| `SFIA` | San Francisco International Airport |
| `SANL` | San Leandro |
| `SHAY` | South Hayward |
| `SSAN` | South San Francisco |
| `UCTY` | Union City |
| `WCRK` | Walnut Creek |
| `WARM` | Warm Springs/South Fremont |
| `WDUB` | West Dublin/Pleasanton |
| `WOAK` | West Oakland |

## Installation

### 1. Build and Test

```bash
swift test
```

```bash
xcodebuild \
  -project BartTrack.xcodeproj \
  -scheme BartTrack \
  -configuration Debug \
  -derivedDataPath .build/XcodeDerivedData \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_IDENTITY=- \
  build
```

### 2. Uninstall the Previous Version

The repository includes a reusable script:

```bash
bash scripts/uninstall-barttrack.sh
```

The script:

- Stops the `BartTrack.app` and Widget extension processes.
- Unregisters the old extension from `pluginkit`.
- Removes `~/Applications/BartTrack.app`.
- Checks for remaining processes and registrations.

### 3. Install the New Version

```bash
mkdir -p "$HOME/Applications"
```

```bash
ditto \
  .build/XcodeDerivedData/Build/Products/Debug/BartTrack.app \
  "$HOME/Applications/BartTrack.app"
```

### 4. Register the Widget Extension

```bash
pluginkit -a "$HOME/Applications/BartTrack.app/Contents/PlugIns/BartTrackWidgetExtension.appex"
```

Verify the registration:

```bash
pluginkit -m -A -D -v -i com.local.BartTrack.WidgetExtension
```

A successful registration looks similar to:

```text
com.local.BartTrack.WidgetExtension(1.0) ... ~/Applications/BartTrack.app/Contents/PlugIns/BartTrackWidgetExtension.appex
```

### 5. Open the App

```bash
open "$HOME/Applications/BartTrack.app"
```

When opened, the app writes the default configuration and requests a widget refresh.

## Add the Desktop Widget

After installing and opening the app:

1. Right-click an empty area of the macOS desktop.
2. Select `Edit Widgets...`.
3. Search for `Daly City BART` or `Bart Track`.
4. Select a size such as small, medium, or large.
5. Drag it to the desktop or Notification Center.

The widget is currently still named `Daly City BART` in the system widget picker, even if you change the origin station. Its data follows the `station` value in your configuration.

## Uninstallation

```bash
bash scripts/uninstall-barttrack.sh
```

The script does not remove the configuration file or debug log. To remove those as well:

```bash
rm -rf "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack"
```

Warning: this command deletes both `settings.json` and `debug.log`.

## Data Source

The current implementation uses BART's Legacy ETD JSON endpoint:

```text
https://api.bart.gov/api/etd.aspx?cmd=etd&orig=DALY&key=MW9S-E7SL-26DU-VV8V&json=y
```

At runtime, `orig` is replaced by the configured `station`, for example:

```text
https://api.bart.gov/api/etd.aspx?cmd=etd&orig=EMBR&key=...&json=y
```

Requests, decoding, and presentation are separated in the codebase:

- `Sources/BartTrackCore`: BART requests, ETD decoding, configuration, and debug logging.
- `Sources/BartTrackWidgetUI`: widget UI and layout rules.
- `Sources/BartTrackWidgetKit`: WidgetKit timeline provider and refresh policy.
- `Xcode/BartTrackApp`: main app settings UI.

A future GTFS / GTFS-RT migration can primarily replace the data source in Core without rewriting the widget UI.

## Why Does the Widget Show OLD / STALE?

The widget header displays the time of the most recently generated data. When the data expires, it shows:

- Small: `OLD`
- Medium / Large: `STALE HH:mm`

Current timeline policy:

- Request another system refresh after approximately 30 seconds.
- Include a stale entry scheduled 90 seconds later.
- Show `OLD` / `STALE` if macOS WidgetKit does not call the provider again within 90 seconds.

This does not necessarily indicate a BART API error. macOS may delay widget refreshes according to system policy.

## Debug Log

The debug log is located at:

```text
~/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/debug.log
```

View recent entries with:

```bash
tail -n 80 "$HOME/Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/debug.log"
```

Log prefix:

```text
[BARTTRACK-DEBUG]
```

Common events:

| Event | Meaning |
| --- | --- |
| `timeline.start` | WidgetKit called the provider and began generating a timeline. |
| `service.request.start` | A BART API request started. |
| `service.request.success` | The request succeeded and north/south departures were decoded. |
| `service.request.failure` | The request or decoding failed. |
| `timeline.loaded` | A fresh entry was generated successfully. |
| `timeline.complete` | The provider returned its timeline to WidgetKit. |
| `app.openURL` | The main app received a `barttrack://...` deep link. |
| `app.openLiveBart` | The app is forwarding the `LIVE BART` deep link to the configured web page. |

To diagnose `OLD`:

1. Open the app after seeing `OLD` and inspect the Debug Log section.
2. If `service.request.failure` appears, the BART request or network failed.
3. If there is no failure but more than 90 seconds pass between `timeline.start` events, macOS WidgetKit did not call the provider on time.
4. If `timeline.start` appears frequently while the UI remains `OLD`, the system cache or widget view may not be updating; remove and re-add the widget or restart the relevant widget processes.

## Development Commands

Run tests:

```bash
swift test
```

Generate a widget preview image:

```bash
swift run BartTrackSnapshot widget-preview.png
```

Open the Xcode project:

```bash
open BartTrack.xcodeproj
```

Inspect Git history:

```bash
git log --oneline
```

Revert the latest commit:

```bash
git revert HEAD
```

Revert a specific commit:

```bash
git revert <commit-sha>
```
