# XO Arena contributor guide

## Purpose

XO Arena is a Flutter tic tac toe application where one human plays against a CPU. Keep the product compact, polished, accessible, and easy to explain. Prefer a complete, coherent core experience over a broad feature set.

## Before changing code

1. Read `README.md` for setup, architecture, and current capabilities.
2. Inspect nearby source and tests before choosing a pattern.
3. Check `git status` and preserve unrelated user changes.
4. Keep each change limited to the requested scope.

## Toolchain

Use repository Make targets. FVM pins Flutter 3.44.0 and Dart 3.12.0.

```sh
make install
make run
make sounds
make generate
make format
make format-check
make analyze
make test
make check
```

Run `make sounds` after changing synthesized audio definitions. Run `make generate` after changing ARB translations, Riverpod annotations, Freezed models, or JSON serialization declarations. Generated localization, `*.g.dart`, and `*.freezed.dart` files are ignored and must not be committed.

Before handing off code, run targeted tests during development, then `make check`. If full verification cannot run, report exact command and failure.

## Current state

Repository currently contains:

* Home, Game, and History routes using GoRouter.
* Immutable Board and Game domain models with pure win and draw evaluation.
* Easy, Medium, and deterministic Minimax CPU strategies.
* Riverpod orchestration with input locking, restart invalidation, and completed game persistence.
* SharedPreferences backed game history and application settings behind repository contracts.
* Typed ARB localization with English as current supported locale.
* Synthesized gameplay cues with persisted mute control.
* Debug only Riverpod state observation.
* Responsive, accessible Home, Game, History, and Settings experiences with reduced motion support.
* Unit, controller, widget, architecture, and golden tests covering core behavior and visual states.

Keep this section and `README.md` aligned with shipped behavior and documented limitations.

## Core experience

* Responsive 3 by 3 board.
* Human versus CPU play.
* Explicit in progress, win, and draw states.
* Restart flow.
* Clear interaction lock while CPU is choosing a move.
* Accessible semantics and touch targets.
* Persisted completed game history only where it supports visible behavior.

## Architecture

Use pragmatic Clean Architecture with feature first organization:

```text
Presentation -> Use cases -> Domain contracts <- Data
```

Dependency rules:

* Domain code stays independent from Flutter, Riverpod, GoRouter, and SharedPreferences.
* Presentation may depend on domain entities, services, use cases, and public providers.
* Data implements contracts owned by domain.
* Features must not import another feature's presentation or internal implementation.
* Move a concept into `core` or `shared` only when multiple features genuinely own it.
* Add abstractions at real boundaries. Avoid one line wrappers with no testing or dependency value.

Expected game boundaries:

* Immutable board and game state in game domain.
* Pure game rule evaluation.
* Pure CPU strategy interface and implementations.
* Controller responsible for turn orchestration and asynchronous CPU lifecycle.
* Presentation responsible only for rendering state and forwarding intent.

History is a shared boundary because Game writes records and History reads them. Preserve repository and local data source separation around SharedPreferences.

## Game domain rules

Represent player identity separately from board mark when choices can vary. Board operations must reject occupied cells without mutation. Game evaluation must distinguish active play, wins, and draws. A full winning board is a win, not a draw.

Keep winning patterns and CPU algorithms deterministic. Preferred hard CPU behavior uses pure Minimax. Depth aware scoring should prefer quicker wins and delay unavoidable losses. Stable move ordering makes tests reproducible.

Invalid actions must be explicit through a typed result, controlled domain exception, or unchanged state. UI checks alone do not enforce business rules.

## Riverpod and async behavior

Use Riverpod for state management and dependency composition, not for domain logic.

* `ref.watch` renders reactive state.
* `ref.read` triggers actions without subscribing.
* `ref.listen` handles transition based UI effects.
* Override dependencies in `ProviderContainer` tests.
* Keep CPU delay and stale result protection in controller logic, not widgets.
* Disable human input while CPU work is pending.
* After `await`, check `mounted` before using `State`, or `context.mounted` before using `BuildContext`.
* Restarting must invalidate any pending CPU result logically.

Use `ConsumerWidget` unless local lifecycle state is required. Do not add hooks without a concrete lifecycle reuse need.

## UI and accessibility

Keep interface sporty, restrained, and responsive. Reuse existing colors, spacing, and theme tokens before adding new design system APIs.

* Use `SafeArea` where system UI can overlap content.
* Support small phones, reasonable landscape layouts, and text scaling.
* Make interactive targets at least 48 by 48 logical pixels.
* Add Semantics labels for empty, X, and O cells.
* Never communicate state through color alone.
* Highlight winning cells and make disabled state visible.
* Keep motion short and functional.

## Tests

Favor many pure domain tests, targeted controller tests, and fewer widget tests.

Minimum game coverage:

* All eight winning patterns.
* Partial boards without a winner.
* Draw and full board win distinction.
* Valid and invalid moves.
* No moves after completion.
* Immediate CPU win and immediate human win block.
* CPU never chooses an occupied cell.
* Deterministic CPU choice when scores tie.
* Human move followed by CPU transition.
* Input lock during CPU work.
* Restart while CPU work is pending.
* Nine rendered cells, visible marks, result copy, and reset behavior.

Use manual fakes when they stay clearer than a mocking dependency. Every bug fix should include a regression test when practical.

## Code style

Follow `flutter_lints` and existing Dart conventions. Prefer immutable values, small cohesive types, exhaustive state handling, and explicit names. Keep build methods readable by extracting meaningful widgets, not arbitrary fragments.

Do not add a dependency unless it solves a current problem. Update `pubspec.yaml`, generated code, tests, and README together when a dependency or architectural boundary changes.

## Documentation

Keep `README.md` accurate for setup, supported behavior, architecture, testing, decisions, and limitations. Record important tradeoffs in its decision section or a focused ADR if discussion outgrows README. Never claim tests or features that have not been verified.

## Git hygiene

Use small, intentional commits when commits are requested. Do not commit secrets, local SDK files, build outputs, generated Dart sources, private working notes, or local agent context. Do not rewrite user history or discard unrelated changes.
