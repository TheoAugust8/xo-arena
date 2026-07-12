# XO Arena

XO Arena is a Flutter tic tac toe application built around a focused Human versus CPU experience. The project favors clear domain rules, pragmatic Clean Architecture, deterministic behavior, accessibility, and tests over unnecessary feature breadth.

## Product scope

Core target:

* Responsive 3 by 3 board.
* Human versus CPU play.
* Explicit active game, win, and draw states.
* Restart support.
* Locked interaction while CPU is choosing a move.
* Accessible cell semantics and touch targets.
* Persisted completed game history.

The product keeps its experience focused on a single game flow, with optional first player selection, difficulty levels, small functional animations, discreet haptics, and golden tests.

## Prerequisites

Install:

* [Git](https://git-scm.com/)
* [FVM](https://fvm.app/), or Dart SDK for automatic FVM installation
* Flutter 3.44.0 through FVM
* Platform tooling for selected device, such as Android Studio with Android SDK or Xcode for Apple platforms

## Installation

```sh
git clone https://github.com/TheoAugust8/xo-arena.git
cd xo-arena
make install
```

`make install` checks for FVM. If unavailable, it requests confirmation before installing FVM 3.1.3 through Dart. It then reads `.fvmrc`, installs pinned Flutter SDK, fetches dependencies, and generates required Dart sources.

## Run application

Connect a device or start a simulator, then run:

```sh
make run
```

## Development commands

```sh
make get              # Fetch Dart and Flutter dependencies through FVM
make run              # Run XO Arena
make format           # Format Dart files
make format-check     # Check Dart formatting
make analyze          # Run static analysis
make test             # Run test suite
make generate         # Generate Riverpod, Freezed, and JSON sources
make generate-watch   # Watch declarations and regenerate sources
make check            # Generate, check formatting, analyze, and test
make clean            # Clean Flutter outputs and restore dependencies
```

Run `make generate` after changing Riverpod annotations, Freezed models, or JSON serialization declarations. Generated `*.g.dart` and `*.freezed.dart` files are intentionally ignored by Git.

## Technical stack

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.44.0 |
| Language | Dart 3.12.0 through Flutter |
| State management and DI | Riverpod 3 with code generation |
| Navigation | GoRouter |
| Immutable persisted models | Freezed |
| Local persistence | SharedPreferences |
| Tests | flutter_test and manual fakes |
| Code generation | build_runner, riverpod_generator, Freezed, json_serializable |
| Toolchain | FVM and Make |
| Continuous integration | GitHub Actions |

## Architecture

Project uses pragmatic Clean Architecture with feature first organization.

```text
Presentation -> Use cases -> Domain contracts <- Data
```

Dependency rules:

* Domain stays independent from Flutter, Riverpod, GoRouter, and SharedPreferences.
* Presentation depends on domain concepts, use cases, and public providers.
* Data implements contracts owned by domain.
* Features do not import another feature's presentation or internal implementation.
* Shared code exists only when several features genuinely depend on same concept.
* Abstractions belong at useful boundaries, not around every class.

Riverpod acts as composition layer. Generated providers wire dependencies and expose asynchronous UI state without introducing framework dependencies into domain code.

## Folder structure

```text
lib/
  app/
    app.dart                   Application root
    router.dart                Home, Game, and History routes
  core/
    design_system/             Colors, spacing, and theme
  features/
    home/
      presentation/            Home screen
    game/
      presentation/            Game screen
      usecases/                Completed game persistence use case
    history/
      presentation/            History screen and Riverpod composition
      usecases/                Read, delete, and clear history
  shared/
    game_records/
      domain/                  GameRecord and repository contract
      data/
        datasources/           SharedPreferences access
        repositories/          Repository implementation
test/
  features/                    Feature widget and use case tests
  shared/                      Domain and data tests
```

`shared/game_records` is a small shared boundary. Game can write completed records, History reads and manages them, and neither feature depends on another feature's presentation code.

## State management

[Riverpod](https://riverpod.dev/) manages dependency composition and asynchronous History state.

`gameHistoryProvider` loads persisted records. After delete or clear operations, History invalidates provider so current local state is loaded again. Mutation controls remain disabled while an operation is pending.

The game controller owns turn orchestration, CPU waiting state, stale asynchronous result protection, and restart behavior. Pure win rules and CPU algorithms remain outside Riverpod.

## Persistence

`GameRecord` is immutable Freezed model. Freezed provides value equality and `copyWith`; json_serializable provides JSON conversion.

`GameRecordRepository` belongs to domain. `GameRecordRepositoryImpl` delegates to `GameRecordLocalDataSource`, while `SharedPreferencesGameRecordLocalDataSource` owns storage format and local mutations.

Local data source serializes write operations. Concurrent save, delete, and clear calls cannot overwrite each other through overlapping read and write cycles.

## Navigation

[GoRouter](https://pub.dev/packages/go_router) defines three routes:

| Path | Screen | Role |
| --- | --- | --- |
| `/` | Home | Entry point and navigation |
| `/game` | Game | Human versus CPU game flow |
| `/history` | History | Stored game record management |

Three explicit destinations keep navigation simple while allowing each flow to evolve independently.

## Testing strategy

Current tests cover:

* Application startup and routes.
* Home navigation.
* History loading, empty state, delete, clear, and mutation locking.
* History use cases and repository delegation.
* GameRecord equality, copying, and JSON conversion.
* SharedPreferences serialization and concurrent mutations.
* Completed game persistence use case.

Game coverage:

* All eight winning patterns.
* Draw and full board win distinction.
* Valid and invalid moves.
* No move after completion.
* Immediate CPU win and Human win block.
* CPU never choosing occupied cell.
* Deterministic choice when scores tie.
* Interaction lock during CPU work.
* Restart while CPU result is pending.
* Board rendering, visible marks, result state, and reset behavior.

Pure domain tests should form most of test suite. Riverpod controller tests should use `ProviderContainer` overrides. Widget tests should focus on visible behavior and user interaction.

Run full local quality gate with:

```sh
make check
```

## Technical decisions

### Why Riverpod

Riverpod combines reactive state management and dependency injection with typed providers and straightforward test overrides. It keeps composition explicit without requiring extra ceremony for project size.

### Why GoRouter

Home, Game, and History are distinct destinations. Declarative routes keep navigation visible, testable, and limited to actual product flows.

### Why repository around local persistence

SharedPreferences is an external implementation detail. Repository contract keeps domain independent from storage choice, while local data source isolates serialization and mutation ordering.

### Why Freezed is limited to persisted records

GameRecord benefits from generated equality, copying, and JSON conversion. Simple types should remain plain Dart when generation adds no clear value.

### Why deterministic Minimax is target CPU strategy

Minimax fits 3 by 3 search space, has predictable behavior, and can be tested without Flutter. Depth aware scoring can favor faster wins and slower unavoidable losses. Stable move ordering keeps results reproducible.

### Why no Flutter Hooks

Current lifecycle needs do not justify extra dependency. Standard Flutter and Riverpod APIs remain sufficient. Hooks can be reconsidered when reusable widget lifecycle logic appears.

## Contributing

Read [AGENTS.md](AGENTS.md) before changing code. Keep changes focused, preserve dependency rules, add tests for behavior, and run `make check` before handoff.
