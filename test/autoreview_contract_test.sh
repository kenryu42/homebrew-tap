#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_PATH="$ROOT_DIR/Formula/autoreview.rb"
README_PATH="$ROOT_DIR/README.md"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_exists() {
  local path="$1"
  [[ -f "$path" ]] || fail "expected file to exist: $path"
}

assert_contains() {
  local path="$1"
  local needle="$2"
  grep -Fq "$needle" "$path" || fail "expected $path to contain: $needle"
}

assert_matches() {
  local path="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$path" || fail "expected $path to match regex: $pattern"
}

assert_not_contains() {
  local path="$1"
  local needle="$2"
  if grep -Fq "$needle" "$path"; then
    fail "expected $path to not contain: $needle"
  fi
}

assert_file_exists "$FORMULA_PATH"
assert_file_exists "$README_PATH"

assert_contains "$FORMULA_PATH" "class Autoreview < Formula"
assert_contains "$FORMULA_PATH" 'desc "AI code review orchestrator for review, verification, and fixing"'
assert_contains "$FORMULA_PATH" 'homepage "https://github.com/kenryu42/autoreview"'
assert_contains "$FORMULA_PATH" 'url "https://github.com/kenryu42/autoreview/archive/refs/tags/v0.1.12.tar.gz"'
assert_contains "$FORMULA_PATH" 'sha256 "d8d91ddf5f439f8fb5c55f2ad3ce2a3c02a3732aac50f2bbaa159c2e5d50d513"'
assert_contains "$FORMULA_PATH" 'license "MIT"'
assert_contains "$FORMULA_PATH" 'depends_on "oven-sh/bun/bun"'
assert_contains "$FORMULA_PATH" 'system "bun", "install", "--frozen-lockfile"'
assert_contains "$FORMULA_PATH" 'if OS.mac?'
assert_contains "$FORMULA_PATH" 'Dir.glob("node_modules/**/*.dylib").each do |f|'
assert_contains "$FORMULA_PATH" 'system "gzip", "-9", f'
assert_contains "$FORMULA_PATH" 'libexec.install Dir["*"]'
assert_contains "$FORMULA_PATH" '%w[autoreview rr].each do |cmd|'
assert_contains "$FORMULA_PATH" 'exec "#{bun}" run "#{libexec}/src/cli.ts" "$@"'
assert_contains "$FORMULA_PATH" '(bin/"rrr").write <<~EOS'
assert_contains "$FORMULA_PATH" 'exec "#{bun}" run "#{libexec}/src/cli-rrr.ts" "$@"'
assert_contains "$FORMULA_PATH" 'Dir.glob("#{libexec}/**/*.dylib.gz").each do |f|'
assert_contains "$FORMULA_PATH" 'system "gunzip", f'
assert_contains "$FORMULA_PATH" 'assert_match version.to_s, shell_output("#{bin}/autoreview --version")'
assert_not_contains "$FORMULA_PATH" 'ralph-review'
assert_matches "$FORMULA_PATH" '^  sha256 "[0-9a-f]{64}"$'

assert_contains "$README_PATH" "# Homebrew Tap"
assert_contains "$README_PATH" "autoreview"
assert_contains "$README_PATH" "ralph-review"
assert_contains "$README_PATH" "## Installation"
assert_contains "$README_PATH" "brew install kenryu42/tap/autoreview"
assert_contains "$README_PATH" "## Upgrade"
assert_contains "$README_PATH" "brew upgrade autoreview"
assert_contains "$README_PATH" "## Uninstall"
assert_contains "$README_PATH" "brew uninstall autoreview"
assert_contains "$README_PATH" "brew untap kenryu42/tap"
assert_contains "$README_PATH" "## Legacy Formula"
assert_contains "$README_PATH" "brew install kenryu42/tap/ralph-review"
assert_contains "$README_PATH" "brew upgrade ralph-review"
assert_contains "$README_PATH" "brew uninstall ralph-review"

printf 'PASS: autoreview formula and README contract verified\n'
