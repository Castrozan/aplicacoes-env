.PHONY: help test test-eval test-full test-onboarding fmt lint clean build build-full build-onboarding run shell switch

help:
	@echo "Aplicacoes Env - Development Commands"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run all tests (eval + full deployment)"
	@echo "  make test-eval      - Quick flake evaluation test (Docker)"
	@echo "  make test-full      - Full deployment test with home-manager (Docker)"
	@echo "  make test-onboarding - Onboarding simulation test (Docker)"
	@echo ""
	@echo "Docker:"
	@echo "  make build          - Build quick evaluation test image"
	@echo "  make build-full     - Build full deployment test image"
	@echo "  make build-onboarding - Build onboarding simulation image"
	@echo "  make run            - Run full deployment container interactively"
	@echo "  make shell          - Get a shell in the test container"
	@echo ""
	@echo "Usage:"
	@echo "  make switch         - Build and activate configuration"
	@echo ""
	@echo "Linting & Formatting:"
	@echo "  make lint           - Run Nix linters (statix, deadnix, nixfmt check)"
	@echo "  make fmt            - Format Nix files"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          - Remove build artifacts and Docker images"

NIX_SYSTEM := $(shell nix eval --impure --expr 'builtins.currentSystem' --raw 2>/dev/null || echo "x86_64-linux")

switch:
	@test -n "$(USER)" || { echo "Error: \$$USER is not set"; exit 1; }
	nix run home-manager -- switch --flake ".#$(USER)@$(NIX_SYSTEM)" --impure

test: test-eval test-full

test-eval: build
	@echo "=== Quick Flake Evaluation Test ==="
	docker compose run --rm test-eval

test-full: build-full
	@echo "=== Full Deployment Test ==="
	docker compose run --rm test-full

build:
	@echo "=== Building Quick Test Image ==="
	docker compose build test-eval

build-full:
	@echo "=== Building Full Deployment Test Image ==="
	docker compose build test-full

test-onboarding: build-onboarding
	@echo "=== Onboarding Simulation Test ==="
	docker compose run --rm test-onboarding

build-onboarding:
	@echo "=== Building Onboarding Test Image ==="
	docker compose build test-onboarding

run: build-full
	@echo "=== Running Full Test Container ==="
	docker compose run --rm test-full

shell: build-full
	@echo "=== Opening Shell in Test Container ==="
	docker compose --profile shell run --rm shell

fmt:
	@find . -name '*.nix' -not -path './result*' -not -path './.git/*' -exec nixfmt {} +

lint:
	@statix check . --ignore 'result*'
	@deadnix .
	@find . -name '*.nix' -not -path './result*' -not -path './.git/*' -exec nixfmt --check {} +

clean:
	rm -rf result result-*
	docker compose down --remove-orphans
	docker rmi aplicacoes-env-test:eval aplicacoes-env-test:full aplicacoes-env-test:onboarding 2>/dev/null || true
