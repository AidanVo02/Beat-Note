# beatnote

BeatNote is an offline-first mobile app to capture music ideas fast: title + note + BPM + key + mood + tags.

## MVP (current)
- Create/Edit/Delete ideas
- Search ideas (title/note/tags)
- Clean Material 3 UI + dark mode

## Roadmap
- Offline persistence (SQLite) + export/import JSON
- Voice memos (record + playback) attached to an idea
- Filters (key, bpm range, tags) + sorting options
- Optional sync (backend + MySQL) in v2

## Getting Started

Run on a connected Android phone:

```bash
flutter pub get
flutter run
```

## Project structure
- `lib/app/` app root (theme + routes)
- `lib/core/` shared models/utilities
- `lib/features/ideas/` idea list/editor/detail + repository

## Flutter resources
- https://docs.flutter.dev/
