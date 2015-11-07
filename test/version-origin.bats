#!/usr/bin/env bats

load test_helper

export NODENV_HOOK_PATH="${NODENV_ROOT}/nodenv.d"

setup() {
  mkdir -p "$NODENV_TEST_DIR"
  cd "$NODENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${NODENV_ROOT}/version" ]
  run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$NODENV_ROOT"
  touch "${NODENV_ROOT}/version"
  run nodenv-version-origin
  assert_success "${NODENV_ROOT}/version"
}

@test "detects NODENV_VERSION" {
  NODENV_VERSION=1 run nodenv-version-origin
  assert_success "NODENV_VERSION environment variable"
}

@test "detects local file" {
  touch .node-version
  run nodenv-version-origin
  assert_success "${PWD}/.node-version"
}

@test "detects alternate version file" {
  touch .nodenv-version
  run nodenv-version-origin
  assert_success "${PWD}/.nodenv-version"
}

@test "reports from hook" {
  touch .node-version
  create_hook version-origin test.bash "NODENV_VERSION_ORIGIN=plugin"

  NODENV_VERSION=1 run nodenv-version-origin

  assert_success "plugin"
}
