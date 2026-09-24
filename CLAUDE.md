# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

The `flutter`/`dart` binaries are not on PATH in this environment. Use the full path:
`/home/hugo-alves/development/flutter/bin/flutter` (there are other Flutter SDKs under
`~/fvm/versions/` and `~/development/flutter/` — this is the one this project uses).

```bash
flutter pub get                          # install/update dependencies
flutter analyze                          # static analysis (must be clean before shipping)
flutter test                             # run all tests
flutter test test/movie_list_controller_test.dart   # run a single test file
flutter test --plain-name "toggleFavorite"           # run tests matching a name

# Running/building always needs the TMDB secret file (see "Secrets" below):
flutter run --dart-define-from-file=secrets.json
flutter build apk --debug --dart-define-from-file=secrets.json
flutter build linux --debug --dart-define-from-file=secrets.json   # local debug target only
```

The app is mobile-only by design (see "Platforms" below): `flutter build web/macos/windows`
will fail with "not configured for the web/desktop" — that's intentional, not a bug.

## Secrets (TMDB API token)

The app calls the TMDB API and needs an API Read Access Token (v4, Bearer). It's read at
**compile time** via `String.fromEnvironment('TMDB_READ_ACCESS_TOKEN')` in
`lib/config/tmdb_config.dart`, so it must be passed with `--dart-define-from-file=secrets.json`
on every `run`/`build`/`test` invocation that needs real network calls.

- `secrets.json` (gitignored) holds the real token — copy it from `secrets.example.json` (tracked template).
- **Never edit `secrets.example.json` with a real token** — it is the file that gets committed.
  This has happened before in this repo's history (an editor/tool kept re-writing it); always
  `cat secrets.example.json` after any secrets-related change and confirm it's still the placeholder
  before staging/committing.
- `.vscode/launch.json` already passes `--dart-define-from-file=secrets.json` for VS Code's Run/Debug (F5).
- Without the token, `TmdbRepository` throws a `TmdbException` with an explicit "token não configurado" message rather than failing silently.

## GitHub / `gh` CLI gotcha

Two `gh` accounts are logged in on this machine: `hugoalves-Clickbus` (usually active) and
`Maskhugo` (owns this repo). A `git push` or `gh pr` command will 403 under the wrong account.
Check with `gh auth status`, switch with `gh auth switch --hostname github.com --user Maskhugo`,
and switch back to `hugoalves-Clickbus` once done — don't leave the account switched as a
side effect.

## Delivery workflow

Issues are tracked on GitHub, grouped into milestones that map to the project's version roadmap
(v0.1 setup → v0.2 local state → v0.3 TMDB integration → v0.4 local persistence → v1.0 cloud/social).
Work happens issue-by-issue: check `gh api repos/Maskhugo/Backlog-App/milestones` /
`.../issues` for the current milestone's scope before implementing.

Two project skills encode the delivery flow — invoke them instead of improvising:
- `commit` (global, `~/.claude/skills/commit`): staging + Conventional Commits + AI-assist trailer.
- `ship` (`.claude/skills/ship`): branch → commit → push → PR (with `Closes #N`) → squash-merge → confirm issues closed.

## Architecture

**State**: a single `MovieListController` (`lib/state/movie_list_controller.dart`, a
`ChangeNotifier`) is the one source of truth for the movie list, provided app-wide via
`package:provider` in `lib/main.dart`. There's no per-screen/per-feature state — screens just
`context.watch`/`context.read` this controller.

**Persistence**: `MovieListController` doesn't touch storage directly — it holds a
`MovieRepository` (abstract, `lib/data/movie_repository.dart`) and writes through to it after
every mutation (`addMovie`, `removeMovie`, `toggleWatched`, `toggleFavorite`, `setRating`).
`HiveMovieRepository` is the real implementation (`hive_ce`/`hive_ce_flutter`, storing plain
`Map`s — deliberately no generated `TypeAdapter`s, to avoid a `build_runner` step). Tests use
`FakeMovieRepository` (in-memory, `test/support/fake_movie_repository.dart`) instead — never
exercise Hive in unit/widget tests. On first launch (nothing persisted yet), the controller
seeds from `lib/data/mock_movies.dart` and immediately persists that seed.

**External data**: `TmdbRepository` (`lib/data/tmdb_repository.dart`) is the only thing that
talks to the network (TMDB `/search/movie`). `SearchScreen` is the sole entry point for adding
movies — it replaced an earlier manual title/URL form once TMDB search landed, so there is
intentionally only one "add movie" path. A tapped search result becomes a real `Movie`
(official cover, title, release year) via `MovieListController.addMovie`.

**Model conventions**: `Movie` (`lib/models/movie.dart`) is immutable with a `copyWith`, and its
fields are deliberately `snake_case` (`url_da_capa`, `foi_visto`, etc.) rather than Dart's usual
lowerCamelCase — this is a project-specific choice, not an oversight, so
`analysis_options.yaml` disables `non_constant_identifier_names` to match. Keep new fields on
`Movie` (and any other project identifiers following this convention) in snake_case for
consistency.

**Platforms**: only `android/` and `ios/` are meant to ship. `linux/` is kept solely so
`flutter run/build -d linux` works for fast local iteration; `macos/`, `web/`, and `windows/`
were deliberately deleted. If you need a browser to visually test something (Playwright/manual
QA), regenerate `web/` with `flutter create --platforms=web .`, test, then `rm -rf web build`
and revert any resulting change to `.metadata` — `flutter create` unconditionally rewrites that
file's platform list to whatever you just touched, dropping the untouched platforms, so always
diff/restore it afterward.
