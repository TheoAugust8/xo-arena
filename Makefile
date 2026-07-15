SHELL := /bin/sh

.DEFAULT_GOAL := help

FVM_VERSION := 3.1.3
FVM ?= $(shell command -v fvm 2>/dev/null || printf '%s/bin/fvm' "$${PUB_CACHE:-$$HOME/.pub-cache}")

ifeq ($(strip $(NO_COLOR)),)
XO_RED := \033[38;2;217;43;53m
XO_LIGHT := \033[38;2;240;240;244m
XO_MUTED := \033[38;2;144;144;160m
XO_GREEN := \033[38;2;34;197;94m
XO_YELLOW := \033[38;2;245;158;11m
XO_BOLD := \033[1m
XO_RESET := \033[0m
endif

define announce
	@printf '%b%s%b%b%s%b%b%s%b %b%s%b\n' '$(XO_BOLD)$(XO_RED)' 'X' '$(XO_RESET)' '$(XO_BOLD)$(XO_LIGHT)' 'O' '$(XO_RESET)' '$(XO_BOLD)$(XO_RED)' ' ARENA' '$(XO_RESET)' '$(XO_MUTED)' '· $(1)' '$(XO_RESET)'
endef

.PHONY: help ensure-fvm install get run widgetbook format format-check analyze test coverage integration-test goldens update-goldens sounds generate generate-watch clean check

help:
	@printf '\n%b%s%b%b%s%b%b%s%b\n' '$(XO_BOLD)$(XO_RED)' 'X' '$(XO_RESET)' '$(XO_BOLD)$(XO_LIGHT)' 'O' '$(XO_RESET)' '$(XO_BOLD)$(XO_RED)' ' ARENA' '$(XO_RESET)'
	@printf '%b%s%b\n\n' '$(XO_MUTED)' 'Development console' '$(XO_RESET)'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make install' '$(XO_RESET)' 'Install FVM, Flutter SDK, generated sources, and dependencies'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make get' '$(XO_RESET)' 'Get Dart dependencies'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make run' '$(XO_RESET)' 'Run XO Arena'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make widgetbook' '$(XO_RESET)' 'Run design system catalog'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make format' '$(XO_RESET)' 'Format Dart files'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make format-check' '$(XO_RESET)' 'Check Dart formatting'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make analyze' '$(XO_RESET)' 'Run static analysis'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make test' '$(XO_RESET)' 'Run tests'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make coverage' '$(XO_RESET)' 'Run tests with line and branch coverage gates'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make integration-test DEVICE=macos' '$(XO_RESET)' 'Run full application flows on a target device'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make goldens' '$(XO_RESET)' 'Run visual regression tests'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make update-goldens' '$(XO_RESET)' 'Update inspected visual baselines'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make sounds' '$(XO_RESET)' 'Regenerate synthesized game sounds'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make generate' '$(XO_RESET)' 'Run code generation'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make generate-watch' '$(XO_RESET)' 'Watch generated sources'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make clean' '$(XO_RESET)' 'Clean Flutter build and get dependencies'
	@printf '  %b%-20s%b %s\n' '$(XO_RED)' 'make check' '$(XO_RESET)' 'Run full quality gate'
	@printf '\n%b%s%b\n' '$(XO_MUTED)' 'Set NO_COLOR=1 to disable ANSI colors.' '$(XO_RESET)'

ensure-fvm:
	@if command -v "$(FVM)" >/dev/null 2>&1; then \
		printf '%b%s%b\n' '$(XO_GREEN)' '✓ FVM is installed' '$(XO_RESET)'; \
	else \
		printf '%b%s%b' '$(XO_YELLOW)' 'FVM is not installed. Install FVM $(FVM_VERSION) now? [y/N] ' '$(XO_RESET)'; \
		read answer; \
		case "$$answer" in \
			[yY]|[yY][eE][sS]) \
				if ! command -v dart >/dev/null 2>&1; then \
					printf '%b%s%b\n' '$(XO_RED)' 'Dart SDK is required to install FVM. Install Dart, then run make install again.' '$(XO_RESET)'; \
					exit 1; \
				fi; \
				dart pub global activate fvm $(FVM_VERSION); \
				if ! command -v "$(FVM)" >/dev/null 2>&1; then \
					printf '%b%s%b\n' '$(XO_RED)' 'FVM installation completed but its executable is unavailable.' '$(XO_RESET)'; \
					printf '%b%s%b\n' '$(XO_MUTED)' 'Add Dart pub cache bin directory to PATH, then run make install again.' '$(XO_RESET)'; \
					exit 1; \
				fi; \
				;; \
			*) \
				printf '%b%s%b\n' '$(XO_RED)' 'FVM is required. Installation cancelled.' '$(XO_RESET)'; \
				exit 1; \
		esac; \
	fi

install: ensure-fvm
	$(call announce,Installing Flutter SDK and dependencies)
	@$(FVM) install
	@$(MAKE) get
	@$(MAKE) generate

get: ensure-fvm
	$(call announce,Getting dependencies)
	@$(FVM) flutter pub get

run: ensure-fvm
	$(call announce,Running game)
	@$(FVM) flutter run

widgetbook: ensure-fvm
	$(call announce,Running design system catalog)
	@$(FVM) flutter run -t tool/widgetbook/main.dart

format: ensure-fvm
	$(call announce,Formatting Dart files)
	@$(FVM) dart format .

format-check: ensure-fvm
	$(call announce,Checking Dart formatting)
	@$(FVM) dart format --output=none --set-exit-if-changed .

analyze: ensure-fvm
	$(call announce,Analyzing project)
	@$(FVM) flutter analyze

test: ensure-fvm
	$(call announce,Running tests)
	@$(FVM) flutter test

coverage: ensure-fvm
	$(call announce,Checking line and branch coverage)
	@$(FVM) flutter test --coverage --branch-coverage --reporter compact
	@$(FVM) dart run tool/check_coverage.dart

integration-test: ensure-fvm
	@if [ -z "$(DEVICE)" ]; then \
		printf '%b%s%b\n' '$(XO_RED)' 'DEVICE is required, for example: make integration-test DEVICE=macos' '$(XO_RESET)'; \
		exit 1; \
	fi
	$(call announce,Running integration tests on $(DEVICE))
	@$(FVM) flutter test integration_test -d "$(DEVICE)"

goldens: ensure-fvm
	$(call announce,Running visual regression tests)
	@$(FVM) flutter test test/goldens/xo_arena_golden_test.dart

update-goldens: ensure-fvm
	$(call announce,Updating visual regression baselines)
	@$(FVM) flutter test --update-goldens test/goldens/xo_arena_golden_test.dart

sounds: ensure-fvm
	$(call announce,Generating game sounds)
	@$(FVM) dart run tool/generate_game_sounds.dart

generate: ensure-fvm
	$(call announce,Generating Dart code)
	@$(FVM) flutter gen-l10n
	@$(FVM) dart run build_runner build

generate-watch: ensure-fvm
	$(call announce,Watching generated Dart code)
	@$(FVM) dart run build_runner watch

clean: ensure-fvm
	$(call announce,Cleaning Flutter build)
	@$(FVM) flutter clean
	@$(MAKE) get

check:
	$(call announce,Running full quality gate)
	@$(MAKE) generate
	@$(MAKE) format-check
	@$(MAKE) analyze
	@$(MAKE) coverage
