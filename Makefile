SHELL := /bin/sh

.DEFAULT_GOAL := help

FVM_VERSION := 3.1.3
FVM ?= $(shell command -v fvm 2>/dev/null || printf '%s/bin/fvm' "$${PUB_CACHE:-$$HOME/.pub-cache}")

.PHONY: help ensure-fvm install get run widgetbook format format-check analyze test generate generate-watch clean check

help:
	@printf '%s\n' 'XO Arena commands:'
	@printf '%s\n' '  make install        Install FVM if approved, Flutter SDK, generated sources, and dependencies'
	@printf '%s\n' '  make get            Get Dart dependencies'
	@printf '%s\n' '  make run            Run the app'
	@printf '%s\n' '  make widgetbook     Run the design system catalog'
	@printf '%s\n' '  make format         Format Dart files'
	@printf '%s\n' '  make format-check   Check Dart formatting'
	@printf '%s\n' '  make analyze        Run static analysis'
	@printf '%s\n' '  make test           Run tests'
	@printf '%s\n' '  make generate       Run code generation'
	@printf '%s\n' '  make generate-watch Watch code generation'
	@printf '%s\n' '  make clean          Clean Flutter build and get dependencies'
	@printf '%s\n' '  make check          Format check, analysis, and tests'

ensure-fvm:
	@if command -v "$(FVM)" >/dev/null 2>&1; then \
		printf '%s\n' 'FVM is installed'; \
	else \
		printf '%s' 'FVM is not installed. Install FVM $(FVM_VERSION) now? [y/N] '; \
		read answer; \
		case "$$answer" in \
			[yY]|[yY][eE][sS]) \
				if ! command -v dart >/dev/null 2>&1; then \
					printf '%s\n' 'Dart SDK is required to install FVM. Install Dart, then run make install again.'; \
					exit 1; \
				fi; \
				dart pub global activate fvm $(FVM_VERSION); \
				if ! command -v "$(FVM)" >/dev/null 2>&1; then \
					printf '%s\n' 'FVM installation completed but its executable is unavailable.'; \
					printf '%s\n' 'Add the Dart pub cache bin directory to PATH, then run make install again.'; \
					exit 1; \
				fi; \
				;; \
			*) \
				printf '%s\n' 'FVM is required. Installation cancelled.'; \
				exit 1; \
		esac; \
	fi

install: ensure-fvm
	@printf '%s\n' 'Installing Flutter SDK and dependencies'
	@$(FVM) install
	@$(MAKE) get
	@$(MAKE) generate

get: ensure-fvm
	@printf '%s\n' 'Getting dependencies'
	@$(FVM) flutter pub get

run: ensure-fvm
	@printf '%s\n' 'Running XO Arena'
	@$(FVM) flutter run

widgetbook: ensure-fvm
	@printf '%s\n' 'Running design system catalog'
	@$(FVM) flutter run -t tool/widgetbook/main.dart

format: ensure-fvm
	@printf '%s\n' 'Formatting Dart files'
	@$(FVM) dart format .

format-check: ensure-fvm
	@printf '%s\n' 'Checking Dart formatting'
	@$(FVM) dart format --output=none --set-exit-if-changed .

analyze: ensure-fvm
	@printf '%s\n' 'Analyzing project'
	@$(FVM) flutter analyze

test: ensure-fvm
	@printf '%s\n' 'Running tests'
	@$(FVM) flutter test

generate: ensure-fvm
	@printf '%s\n' 'Generating Dart code'
	@$(FVM) dart run build_runner build

generate-watch: ensure-fvm
	@printf '%s\n' 'Watching generated Dart code'
	@$(FVM) dart run build_runner watch

clean: ensure-fvm
	@printf '%s\n' 'Cleaning Flutter build'
	@$(FVM) flutter clean
	@$(MAKE) get

check:
	@$(MAKE) generate
	@$(MAKE) format-check
	@$(MAKE) analyze
	@$(MAKE) test
