#!/usr/bin/env bash
# scripts/test-setup-platform.sh
# Verifies setup.sh selects macOS, Linux, and WSL without running installation.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

printf '%s\n' 'Linux version 6.8.0-generic' >"$TEST_DIR/linux"
printf '%s\n' 'Linux version 5.15.153.1-microsoft-standard-WSL2' >"$TEST_DIR/wsl-lower"
printf '%s\n' 'Linux version 4.4.0-19041-Microsoft' >"$TEST_DIR/wsl-upper"

mkdir "$TEST_DIR/bin"
cat >"$TEST_DIR/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TRACE_FILE"
EOF
printf '%s\n' '#!/usr/bin/env bash' >"$TEST_DIR/bin/apt-get"
chmod +x "$TEST_DIR/bin/sudo" "$TEST_DIR/bin/apt-get"

assert_platform() {
  local expected="$1"
  local os_type="$2"
  local version_file="$3"
  local actual

  actual=$(OSTYPE="$os_type" bash -c \
    'source "$1"; detect_platform "$2"; printf "%s:%s\n" "$OS" "$PLATFORM"' \
    _ "$DOTFILES/setup.sh" "$version_file")

  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: expected %s, got %s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

assert_wsl_prerequisites() {
  local trace_file="$TEST_DIR/commands"
  local expected
  local actual

  : >"$trace_file"
  PATH="$TEST_DIR/bin:$PATH" TRACE_FILE="$trace_file" OSTYPE=linux-gnu \
    bash -c 'source "$1"; setup_wsl_prerequisites' _ "$DOTFILES/setup.sh" >/dev/null

  expected=$'-v\napt-get update\nenv DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends build-essential procps curl file git'
  actual=$(cat "$trace_file")
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: expected WSL prerequisites:\n%s\nactual:\n%s\n' \
      "$expected" "$actual" >&2
    exit 1
  fi
}

assert_platform "mac:mac" "darwin24.0" "$TEST_DIR/wsl-lower"
assert_platform "linux:linux" "linux-gnu" "$TEST_DIR/linux"
assert_platform "linux:wsl" "linux-gnu" "$TEST_DIR/wsl-lower"
assert_platform "linux:wsl" "linux-gnu" "$TEST_DIR/wsl-upper"
assert_wsl_prerequisites

echo "PASS: WSL platform detection and prerequisites"
