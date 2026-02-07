#!/usr/bin/env bats
# Example test file - demonstrates BATS testing syntax
#
# To add your own tests:
# 1. Create a new .bats file in tests/scripts/
# 2. Use @test "description" { ... } format
# 3. Run with: make test

@test "nix is available" {
    command -v nix
}

@test "flake.nix exists" {
    [ -f "flake.nix" ]
}

@test "home.nix exists" {
    [ -f "home.nix" ]
}

@test "modules directory exists" {
    [ -d "modules" ]
}

@test "pipx module exists" {
    [ -f "modules/pipx.nix" ]
}

@test "sdkman module exists" {
    [ -f "modules/sdkman.nix" ]
}
