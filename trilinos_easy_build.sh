#!/usr/bin/env bash
# build_trilinos.sh
#-----------------------------------------------------------------------------
# Configure & build Trilinos using a “build‐easy” wrapper.
#-----------------------------------------------------------------------------
set -euo pipefail

show_help() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Required arguments (one of these or the corresponding env var must be provided):
  -s, --trilinos-home            PATH   Path to the Trilinos source directory
  -b, --trilinos-build-easy-dir  PATH   Path to “trilinos-build‐easy” directory

You may also export the following environment variables instead of using flags:
  TRILINOS_HOME
  TRILINOS_BUILD_EASY_DIR

Options:
  -h, --help                          Show this help message and exit
EOF
}

# -----------------------------------------------------------------------------
# Defaults from environment if set
# -----------------------------------------------------------------------------
TRILINOS_HOME="${TRILINOS_HOME:-}"
TRILINOS_BUILD_EASY_DIR="${TRILINOS_BUILD_EASY_DIR:-}"

# -----------------------------------------------------------------------------
# Parse command‐line options
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--trilinos-home)
      TRILINOS_HOME="$2"
      shift 2
      ;;
    -b|--trilinos-build-easy-dir)
      TRILINOS_BUILD_EASY_DIR="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Guards: ensure we have the two required paths
# -----------------------------------------------------------------------------
if [[ -z "$TRILINOS_HOME" ]]; then
  echo "Error: Trilinos source path not set." >&2
  show_help
  exit 1
fi

if [[ -z "$TRILINOS_BUILD_EASY_DIR" ]]; then
  echo "Error: Trilinos build‐easy directory not set." >&2
  show_help
  exit 1
fi

# -----------------------------------------------------------------------------
# Derive the rest of the directories
# -----------------------------------------------------------------------------
TRILINOS_DIR="$TRILINOS_HOME"
TRILINOS_BUILD_DIR="$TRILINOS_DIR/build"
TRILINOS_INSTALL_DIR="$TRILINOS_DIR/install"
CMAKE_WRAPPER_DIR="$TRILINOS_BUILD_EASY_DIR"

echo "Trilinos source dir           : $TRILINOS_DIR"
echo "Trilinos build‐easy directory : $CMAKE_WRAPPER_DIR"
echo "Build directory               : $TRILINOS_BUILD_DIR"
echo "Install prefix                : $TRILINOS_INSTALL_DIR"
echo

# -----------------------------------------------------------------------------
# clear_build: remove stale CMake state
# -----------------------------------------------------------------------------
clear_build() {
  if [[ -d "$TRILINOS_BUILD_DIR" ]]; then
    pushd "$TRILINOS_BUILD_DIR" >/dev/null
    rm -rf CMakeCache.txt CMakeFiles
    popd >/dev/null
  fi
}

# -----------------------------------------------------------------------------
# configure_trilinos: run CMake with the build‐easy wrapper
# -----------------------------------------------------------------------------
configure_trilinos() {
  clear_build
  cmake \
    -S "$TRILINOS_DIR" \
    -B "$TRILINOS_BUILD_DIR" \
    -DCMAKE_INSTALL_PREFIX="$TRILINOS_INSTALL_DIR" \
    -C "$CMAKE_WRAPPER_DIR/build.cmake" \
  |& tee "$TRILINOS_BUILD_DIR/configure.log"
}

# -----------------------------------------------------------------------------
# build_trilinos: build and install
# -----------------------------------------------------------------------------
build_trilinos() {
  pushd "$TRILINOS_BUILD_DIR" >/dev/null
  make -j"$(nproc)"
  make install
  popd >/dev/null
}

# -----------------------------------------------------------------------------
# Main entrypoint
# -----------------------------------------------------------------------------
configure_trilinos
build_trilinos

echo
echo "Trilinos has been built and installed to: $TRILINOS_INSTALL_DIR"
