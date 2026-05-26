# BeatNote – AI Implementation Brief (Flutter, Offline-First)

This document is intended to be pasted into other AI tools to continue building this project consistently.

## 1) Project summary

**BeatNote** is an offline-first mobile app to capture music ideas quickly.

Each idea can store:
- Title
- Freeform note (lyrics/chords/structure/references)
- BPM
- Key (e.g. `C#m`, `Am`)
- Mood (free text)
- Tags (list of strings)
- (Next) Voice memos recorded on-device and attached to an idea
- (Next) Backup/export and import (JSON) for portability

Target: **Android first** (tested on real device). iOS support is optional.

## 2) Current status (already implemented)

Implemented a simple UI scaffold (data is **in-memory only** for now):
- Idea list screen with search
- Create/edit idea screen
- Idea detail screen with chips (BPM/Key/Mood/Tags)
- Material 3 theming + dark mode

Key files:
- App entry: `lib/main.dart`
- App root: `lib/app/beatnote_app.dart`
- Model: `lib/core/models/idea.dart`
- In-memory repository: `lib/features/ideas/idea_repository.dart`
- Screens:
  - `lib/features/ideas/pages/idea_list_page.dart`
  - `lib/features/ideas/pages/idea_editor_page.dart`
  - `lib/features/ideas/pages/idea_detail_page.dart`

## 3) Constraints / preferences

- Keep code in `lib/` using feature-based structure (`lib/features/...`).
- Prefer clean, readable code over over-engineering.
- No Android Studio IDE required (VS Code workflow). Android SDK/adb is assumed on user machine.
- Offline-first: app must be usable without login/network.
- Future v2: optional sync via backend + MySQL, but do **not** implement now unless requested.
- **Coding convention (important):** add a short comment header before each major method/block (e.g., `// --- Save note ---`) so future debugging is easier.

## 4) MVP functional requirements

### 4.1 Ideas
- Create / edit / delete an idea.
- Search ideas by title, note, tags, key, mood.
- Display summary line in list (Key, BPM, Mood, top tags).

### 4.2 Persistence (must-do next)
- Persist ideas locally so they remain after app restart.
- Prefer SQLite-based persistence for portfolio credibility.

### 4.3 Voice memos (must-do after persistence)
- Record audio and attach to an idea.
- List recordings on idea detail, allow playback.
- Store recordings on device storage, keep file paths in DB.

### 4.4 Backup
- Export all data to a JSON file.
- Import from a JSON file (merge/upsert by id).

## 5) Recommended technical approach (preferred)

### 5.1 State management
Add Riverpod to manage repository + reactive UI:
- `flutter_riverpod`
- Provide `IdeaRepository` (and later `Database`) via providers.

### 5.2 Local database
Use Drift (SQLite):
- `drift`
- `drift_flutter`
- `sqlite3_flutter_libs`
- `path_provider`

Schema suggestion:
- `ideas` table:
  - `id TEXT PRIMARY KEY`
  - `title TEXT NOT NULL`
  - `note TEXT NOT NULL`
  - `bpm INTEGER NULL`
  - `music_key TEXT NULL`
  - `mood TEXT NULL`
  - `created_at INTEGER NOT NULL` (epoch ms)
  - `updated_at INTEGER NOT NULL` (epoch ms)
- `tags` table:
  - `id TEXT PRIMARY KEY` (or autoincrement int)
  - `name TEXT UNIQUE NOT NULL`
- `idea_tags` table:
  - `idea_id TEXT NOT NULL`
  - `tag_id TEXT NOT NULL`
  - composite primary key `(idea_id, tag_id)`
- `recordings` table:
  - `id TEXT PRIMARY KEY`
  - `idea_id TEXT NOT NULL`
  - `file_path TEXT NOT NULL`
  - `duration_ms INTEGER NULL`
  - `created_at INTEGER NOT NULL`

Repository API suggestion (high-level):
- `watchIdeas(query, filters)` → Stream<List<Idea>>
- `getIdeaById(id)` → Stream<Idea?>
- `upsertIdea(Idea)`
- `deleteIdea(id)`
- `addRecording(ideaId, Recording)`
- `deleteRecording(recordingId)` (and delete underlying file)

### 5.3 Voice memo
Packages:
- `record` (recording)
- `just_audio` (playback) or `audioplayers` (simpler)
- `permission_handler` (if needed; Android 13+ specifics)

Store files under app documents directory:
- e.g. `${appDocDir}/recordings/{ideaId}/{recordingId}.m4a`

### 5.4 Filtering UI (later)
Add filters on Idea list:
- key dropdown (free text suggestions)
- bpm range slider
- tag multi-select
- sort (newest/oldest, bpm)

## 6) UX requirements (quick but polished)

- Material 3, readable typography.
- Great empty states.
- Fast add flow (FAB → editor).
- Confirm delete with dialog/snackbar undo (optional).
- Keep forms forgiving (BPM optional, Key optional).

## 7) Quality bar / acceptance criteria

Persistence milestone is considered done when:
- Create an idea → close app → reopen → idea still exists.
- Edit/delete persists reliably.
- Search works on persisted data.

Voice memo milestone is considered done when:
- Record memo, save, shows in idea detail.
- Playback works.
- Memo persists after restart.

Backup milestone is considered done when:
- Export creates a JSON file.
- Import restores ideas + tags + recordings metadata (recording audio files optional depending on chosen approach).

## 8) Suggested milestone plan (do in order)

1) Add Riverpod + refactor repository usage
2) Implement Drift database + persistence for ideas/tags
3) Add recordings table + file storage utilities
4) Implement recording + playback UI
5) Implement export/import JSON
6) Add filters + sorting + polish
7) Add CI (GitHub Actions) + simple widget/unit tests

## 9) Commands (developer workflow)

From project root:
- `flutter pub get`
- `flutter run`
- `flutter test`

## 10) Notes for future v2 (do not implement now)

- Optional authentication + sync API
- Backend (Node/Nest/Express) with MySQL
- Upload audio to object storage (S3/R2) and store URLs
- Conflict resolution (last-write-wins or merge)
