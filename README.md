# XO Arena

XO Arena is the Flutter foundation for a Betclic game experience. It provides a focused starting point for building and iterating on the application.

## Prerequisites

Install the following tools before working on the project:

* [Git](https://git-scm.com/)
* [FVM](https://fvm.app/), or Dart SDK for automatic FVM installation
* Flutter 3.44.0, installed and run through FVM
* Platform tooling for the device you use, such as Android Studio with the Android SDK, or Xcode for iOS and macOS

## Installation

Clone the repository, then install the pinned Flutter SDK and project dependencies through FVM:

```sh
git clone https://github.com/TheoAugust8/xo-arena.git
cd xo-arena
make install
```

`make install` checks for FVM first. If FVM is missing, it asks before installing FVM 3.1.3 through Dart. It then reads `.fvmrc`, installs Flutter 3.44.0, fetches dependencies, and generates required Dart sources.

## Run and quality commands

```sh
make run              # Run XO Arena on a connected device or simulator
make get              # Fetch Dart and Flutter dependencies through FVM
make format           # Format Dart files
make format-check     # Check Dart formatting
make analyze          # Run static analysis
make test             # Run the test suite
make check            # Generate sources, then check formatting, analysis, and tests
make generate         # Generate build_runner outputs
make generate-watch   # Watch and regenerate build_runner outputs
make clean            # Clean Flutter outputs and restore dependencies
```

## Technical Stack

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.44.0 |
| Language | Dart 3.12.0 through Flutter |
| State management and DI | Riverpod 3 with code generation |
| Navigation | GoRouter |
| Immutability | Freezed |
| Persistence | SharedPreferences |
| Tests | flutter_test and manual fakes |
| Code generation | build_runner, riverpod_generator, freezed, json_serializable |

## Architecture

The project follows Clean Architecture principles with a feature-first structure.

The dependency rule is:

```text
Presentation → Use cases → Domain contracts ← Data
```

The domain stays independent from Flutter, Riverpod, GoRouter, and SharedPreferences. Business concepts and repository contracts belong to the domain. Use cases orchestrate domain contracts. Data sources own local storage details, while repository implementations expose those details through domain abstractions.

Riverpod is the composition layer. Generated providers wire dependencies and expose asynchronous UI state. They stay outside domain code. History providers currently live beside History presentation because they compose History use cases and local persistence.

## Folder Structure

```text
lib/
  app/
    app.dart                   Application root
    router.dart                GoRouter routes
  core/
    design_system/             Theme, colors, spacing
  features/
    home/
      presentation/            Home screen
    game/
      presentation/            Game screen
      usecases/                Game actions
    history/
      presentation/            History screen and Riverpod composition
      usecases/                History actions
  shared/
    game_records/
      domain/                  GameRecord and repository contract
      data/
        datasources/           Local persistence access
        repositories/          Repository implementations
test/
  features/                    Feature widget and use case tests
  shared/                      Domain and data tests
```

Each feature owns its presentation and use cases. `Home` starts a Game or opens History. `Game` owns live Game behavior and records completed Games. `History` reads and manages completed Game records. There is no standalone Settings feature: game options belong to Home or an active Game.

`shared/game_records` is a deliberately small shared boundary. Game writes completed records, History reads them, and neither feature imports the other feature's presentation or use cases.

## State management

[Riverpod](https://riverpod.dev/) manages application dependencies and asynchronous History state. Providers are generated from `@Riverpod` declarations and kept alive where shared repository lifetime matters.

`gameHistoryProvider` exposes asynchronous History records to the UI. After deleting or clearing a record, the screen invalidates that provider so Riverpod reloads the current local state. History mutation controls are disabled while an operation is running.

Run `make generate` after editing Freezed models or Riverpod provider declarations. Generated `*.freezed.dart` and `*.g.dart` files are intentionally ignored by Git.

## Data models and persistence

`GameRecord` is an immutable Freezed model. Freezed generates value equality and `copyWith`; json_serializable generates JSON conversion. Completed Game records persist locally through SharedPreferences.

The local data source serializes write operations, preventing concurrent save, delete, or clear actions from overwriting each other's changes.

## Navigation and testing

[GoRouter](https://pub.dev/packages/go_router) defines the Home, Game, and History routes. Widget tests cover each feature's visible behavior and navigation. Unit tests cover Game and History use cases, repository delegation, local persistence, generated GameRecord behavior, and concurrent record mutations.

## Collaboration

XO Arena is developed collaboratively by Codex and OpenAI 5.6, with Luna, Terra, and Sol. Keep changes focused, run the relevant quality commands before sharing work, and document notable implementation decisions with the change.
