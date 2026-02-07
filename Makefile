# Makefile for managing aplicacoes-env project

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make build USER=username      - Build configuration for a user"
	@echo "  make switch USER=username     - Build and activate configuration for a user"
	@echo "  make test                     - Run all tests"
	@echo "  make lint                     - Check code formatting"
	@echo "  make format                   - Format all Nix files with alejandra"
	@echo "  make update                   - Update flake inputs"
	@echo "  make update-latest            - Update only nixpkgs-latest"
	@echo "  make clean                    - Remove build artifacts"

.PHONY: build
build:
	@if [ -z "$(USER)" ]; then \
		echo "Error: USER variable is required. Usage: make build USER=lucas.zanoni"; \
		exit 1; \
	fi
	@echo "Building configuration for $(USER) (dry-run)..."
	nix run home-manager -- build --flake .#$(USER)@x86_64-linux

.PHONY: switch
switch:
	@if [ -z "$(USER)" ]; then \
		echo "Error: USER variable is required. Usage: make switch USER=lucas.zanoni"; \
		exit 1; \
	fi
	@echo "Building and activating configuration for $(USER)..."
	nix run home-manager -- switch --flake .#$(USER)@x86_64-linux

.PHONY: test
test:
	@echo "Running tests..."
	@chmod +x tests/*.sh
	./tests/run-tests.sh

.PHONY: lint
lint:
	@echo "Checking code formatting..."
	nix run nixpkgs#alejandra -- --check .

.PHONY: format
format:
	@echo "Formatting Nix files..."
	nix run nixpkgs#alejandra -- .

.PHONY: update
update:
	@echo "Updating all flake inputs..."
	nix flake update

.PHONY: update-latest
update-latest:
	@echo "Updating nixpkgs-latest..."
	nix flake update nixpkgs-latest

.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf result result-*

.PHONY: repl
repl:
	@echo "Starting Nix REPL..."
	@echo "Tip: Use :lf .#homeConfigurations.lucas.zanoni@x86_64-linux to load a config"
	nix repl
