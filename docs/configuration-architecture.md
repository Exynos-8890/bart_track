# BartTrack Configuration Architecture

Status: proposed design, based on commit `fc325c4`, the reverted experiment in
`1181a20`, BartTrack debug logs, and macOS WidgetKit system logs.

## Outcome

The next configurable widget should use named commute profiles.

- The BartTrack app owns profile definitions.
- Each widget instance owns only the identifier of the profile it selected.
- WidgetKit receives that identifier through `AppIntentConfiguration`.
- The timeline engine resolves the current profile, fetches or reuses station
  data, applies the walking-time policy, and returns a complete timeline model.

This preserves both required workflows:

1. Two widget instances can show different stations and walking times.
2. Editing a profile in the BartTrack app updates every widget that selected it.

The earlier experiment stored station, walking time, and filtering directly in
each WidgetKit intent. That made per-instance values work, but it made the app's
settings a second, weaker source of truth that could not update existing widget
instances.

## Evidence From The Reverted Experiment

The runtime evidence does not show a failure in the BART request or in the
AppIntent timeline provider:

- WidgetKit serialized one instance as Daly City with an 8-minute walk.
- WidgetKit serialized another instance as 16th St. Mission with a 14-minute
  walk.
- Both timeline requests completed successfully and loaded BART data.

The installation did expose an identity and migration problem:

- `BartTrackWidget` changed in place from `StaticConfiguration` to
  `AppIntentConfiguration`.
- The widget kind remained `BartTrackWidget`.
- The app bundle identifier, extension bundle identifier, short version, and
  build version all remained unchanged.
- macOS retained serialized AppIntent widget instances while the installed
  extension was later replaced by the static implementation.
- Switching build and installed extension paths produced transient
  `Invalid bundle record for current process` failures until Launch Services
  was fully re-registered.

The exact user-visible symptom was not captured as a deterministic test, so the
logs do not prove one exclusive root cause. They do prove that the configuration
values reached the provider correctly, and that changing configuration type and
installation identity in place is unsafe.

## Problems In The Current Shape

### Configuration has mixed ownership

`BartTrackSettings` currently combines two unrelated lifetimes:

- App preferences: Dock visibility and app behavior.
- Journey settings: station, walking time, and departure filtering.

In the static widget, the app-owned JSON file is the single source of truth. In
the experiment, WidgetKit became the source of truth for journey settings while
the app still displayed and saved similarly named values. Calling
`reloadAllTimelines()` does not rewrite serialized intent parameters, so the app
cannot edit an existing widget's direct intent values.

### Shared storage depends on another app's container path

The main app writes directly into the widget extension's sandbox container by
constructing a path from its bundle identifier. This works for the current local
build but is not a stable sharing seam. The app and extension should use an App
Group container with entitlements on both targets.

### The data model mixes source data and display policy

`DepartureBoard` contains `walkingMinutes` and owns catchability filtering. A
BART response is station data; walking time is a user's journey policy. Keeping
them together prevents clean reuse when two profiles share a station but have
different walking times.

### Timeline orchestration is difficult to test as a whole

The provider currently loads configuration, performs network I/O, constructs
placeholders, decides freshness, logs, and builds WidgetKit entries. Tests cover
individual helpers but do not exercise one interface that represents the full
timeline behavior.

### Failure fallback can look like transit data

On a request error, the provider displays hard-coded placeholder departures
with an error badge. Placeholder values are appropriate for the widget gallery,
but not as runtime fallback data. Runtime failure should use a cached last-known
snapshot or an explicit unavailable state.

### Build identity is not a release mechanism

Stable and experimental builds currently share all identifiers and version `1`.
Installing a test build mutates the same WidgetKit and Launch Services records
used by the stable desktop widgets. This makes rollback unreliable even when the
source code itself is correct.

## Proposed Domain Model

```swift
struct CommuteProfile: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var station: BartStation
    var walkingMinutes: Int
    var showsOnlyCatchableDepartures: Bool
}

struct AppPreferences: Codable, Equatable, Sendable {
    var showsDockIcon: Bool
}

struct DepartureSnapshot: Codable, Equatable, Sendable {
    let station: BartStation
    let fetchedAt: Date
    let northbound: [TrainDeparture]
    let southbound: [TrainDeparture]
}
```

The BART URL is derived from `profile.station`; it is not stored as mutable
configuration. If a custom URL remains necessary, it belongs in app preferences
or a separate link policy, not in a commute profile.

## Deep Modules And Seams

### 1. CommuteProfileCatalog

Interface:

```swift
protocol CommuteProfileCatalog: Sendable {
    func profiles() throws -> [CommuteProfile]
    func profile(id: UUID) throws -> CommuteProfile?
    func save(_ profiles: [CommuteProfile]) throws
}
```

The production adapter stores one atomic JSON document in the App Group. Tests
use an in-memory adapter. This is a real seam because both adapters are required.
Validation, default profile creation, schema migration, and duplicate-name rules
stay inside the module.

### 2. DepartureRepository

Interface:

```swift
protocol DepartureRepository: Sendable {
    func snapshot(for station: BartStation, now: Date) async throws
        -> DepartureSnapshot
}
```

Its implementation owns the BART request, decoding, a short station-keyed TTL,
last-known-good cache, and source/retrieval timestamps. The production adapter
uses BART ETD first; tests use fixture data. A later GTFS-RT adapter can replace
the remote implementation without changing widget configuration or UI.

### 3. WidgetTimelineEngine

Interface:

```swift
struct WidgetTimelineRequest: Sendable {
    let profileID: UUID
    let family: WidgetFamilyClass
    let now: Date
}

protocol WidgetTimelineBuilding: Sendable {
    func timeline(for request: WidgetTimelineRequest) async
        -> WidgetTimelineModel
}
```

This is the main deep module. It resolves the profile, requests a station
snapshot, applies walking-time filtering, limits rows by family, derives the
live BART URL, calculates freshness, and chooses cached/error presentation. Its
result is independent of WidgetKit, so the full behavior can be tested with an
in-memory profile catalog, fixture departure repository, and fixed clock.

The WidgetKit provider becomes a small adapter that converts an intent to a
`WidgetTimelineRequest` and converts the result to `Timeline<Entry>`.

### 4. AppIntent profile adapter

The intent stores one `CommuteProfileEntity.ID`, not a copy of every journey
field. An `EntityQuery` reads available profiles from the App Group catalog.
This avoids the 50-case duplicate station enum and keeps `BartStation` as the
single station catalog.

If a profile is renamed or edited, its stable UUID remains unchanged. If a
profile is deleted, the timeline engine returns an explicit "Choose profile"
state instead of silently falling back to Daly City.

## Ownership Flow

```text
BartTrack app
    -> edits CommuteProfileCatalog in App Group
    -> calls reloadAllTimelines()

Widget instance
    -> stores selected profile UUID in WidgetKit intent

Widget provider
    -> WidgetTimelineEngine(profile UUID)
       -> CommuteProfileCatalog
       -> DepartureRepository(station)
       -> display rows + freshness + live URL
```

There is one owner for profile contents and one owner for profile selection.
Neither side stores a competing copy of station or walking time.

## Widget Migration Strategy

Do not change the existing widget kind in place again.

1. Keep the current static widget kind `BartTrackWidget` for a migration
   release and label it as legacy/global configuration.
2. Add the profile-based widget under a new kind such as
   `BartTrackProfileWidget.v2`.
3. Include both widgets in the WidgetBundle while users move their desktop
   placements.
4. Retire the legacy kind only after the new widget has been manually verified.

The new kind gives WidgetKit a clean serialized configuration namespace. It
also provides a deterministic comparison: legacy instances must keep using the
global JSON settings, while v2 instances must resolve their selected profile.

## Stable And Experimental Installation Channels

Experimental builds must not replace stable widgets.

- Stable app: `com.local.BartTrack`
- Stable extension: `com.local.BartTrack.WidgetExtension`
- Experimental app: `com.local.BartTrack.Dev`
- Experimental extension: `com.local.BartTrack.Dev.WidgetExtension`
- Experimental widget kind: a `.dev` kind distinct from the stable kind

Each build must also receive a monotonically increasing `CFBundleVersion`.
The install script should stop both app and extension processes, unregister the
exact old paths, install, register Launch Services, register the extension, and
verify that the running process path matches the intended channel.

## Freshness And Request Policy

WidgetKit does not guarantee a 30-second callback schedule. The interface should
make this visible rather than promise real-time execution that macOS does not
provide.

- Record `fetchedAt` separately from the timeline entry date.
- Cache successful snapshots by station for a short TTL so two widgets using
  the same station do not issue duplicate requests within a few seconds.
- Keep the last successful snapshot and display its exact age when a refresh
  fails.
- Never show gallery placeholder trains as runtime data.
- Log profile ID, station, requestedAt, fetchedAt, cache hit/miss, response
  outcome, and the next requested refresh date.

## Test Surface

Tests should target the deep module interface rather than private helpers.

Required scenarios:

1. Two profile IDs produce different stations and walking filters.
2. Editing one profile changes every timeline that references its ID.
3. Two profiles at the same station share a fresh station snapshot but produce
   different visible rows.
4. A deleted profile produces a choose-profile state.
5. A network failure uses a last-known-good snapshot with accurate age.
6. A network failure without cache produces unavailable state and no fake rows.
7. Legacy and v2 widget kinds coexist without sharing serialized configuration.
8. Stable and experimental bundle identifiers can be installed simultaneously.

The first end-to-end manual verification should place a Daly City/8-minute v2
widget next to a 16th St. Mission/14-minute v2 widget and compare their logged
profile IDs, request URLs, visible rows, and BART live links.

## Safe Implementation Order

1. Add separate stable/dev build identities and a verified install script.
2. Split `AppPreferences`, `CommuteProfile`, and `DepartureSnapshot` without
   changing the current static widget behavior.
3. Add the App Group profile catalog and migrate the existing global journey
   settings into one default profile.
4. Add `DepartureRepository` caching and runtime fallback tests.
5. Add `WidgetTimelineEngine` and move orchestration behind its interface.
6. Add the new v2 widget kind with a profile-selection AppIntent.
7. Update the app UI to create, rename, edit, and delete profiles.
8. Install the dev channel beside stable, perform two-widget visual/runtime QA,
   then promote the verified build to stable.

This order keeps the currently working static widget installable at every step
and prevents another configuration-schema rollback from corrupting desktop
instances.
