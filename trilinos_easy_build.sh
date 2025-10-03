#!/usr/bin/env bash
# build_trilinos.sh
#-----------------------------------------------------------------------------
# Configure & build Trilinos using a “build‐easy” wrapper with parallel jobs.
#-----------------------------------------------------------------------------
set -euo pipefail

show_help() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Required arguments (flags or environment variables):
  -s, --trilinos-home            PATH   Trilinos source directory
  -b, --trilinos-build-easy-dir  PATH   build‐easy wrapper directory

Optional arguments:
  -j, --number-jobs              N      Number of parallel build jobs
  -h, --help                         Show this help and exit

Environment variables (used if flags not provided):
  TRILINOS_HOME
  TRILINOS_BUILD_EASY_DIR
  BUILD_JOBS
  SLURM_CPUS_ON_NODE
  FLUX_CPUS_PER_TASK
EOF
}

# -----------------------------------------------------------------------------
# Defaults from environment
# -----------------------------------------------------------------------------
TRILINOS_HOME="${TRILINOS_HOME:-}"
TRILINOS_BUILD_EASY_DIR="${TRILINOS_BUILD_EASY_DIR:-}"
NUMBER_JOBS="${NUMBER_JOBS:-}"
BUILD_JOBS="${BUILD_JOBS:-}"

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
    -j|--number-jobs)
      NUMBER_JOBS="$2"
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
# Guards for required paths
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
# Determine parallel job count
# -----------------------------------------------------------------------------
if [[ -n "$NUMBER_JOBS" ]]; then
  PARALLEL_JOBS=$NUMBER_JOBS
elif [[ -n "$BUILD_JOBS" ]]; then
  PARALLEL_JOBS=$BUILD_JOBS
elif [[ -n "${SLURM_CPUS_ON_NODE:-}" ]]; then
  PARALLEL_JOBS=$SLURM_CPUS_ON_NODE
elif [[ -n "${FLUX_CPUS_PER_TASK:-}" ]]; then
  PARALLEL_JOBS=$FLUX_CPUS_PER_TASK
elif command -v nproc &>/dev/null; then
  PARALLEL_JOBS=$(nproc)
elif command -v getconf &>/dev/null; then
  PARALLEL_JOBS=$(getconf _NPROCESSORS_ONLN)
else
  PARALLEL_JOBS=1
fi

# -----------------------------------------------------------------------------
# Derive build/install directories
# -----------------------------------------------------------------------------
TRILINOS_DIR="$TRILINOS_HOME"
TRILINOS_BUILD_DIR="$TRILINOS_DIR/build"
TRILINOS_INSTALL_DIR="$TRILINOS_DIR/install"
CMAKE_WRAPPER_DIR="$TRILINOS_BUILD_EASY_DIR"

echo "Trilinos source dir           : $TRILINOS_DIR"
echo "Trilinos build‐easy directory : $CMAKE_WRAPPER_DIR"
echo "Build directory               : $TRILINOS_BUILD_DIR"
echo "Install prefix                : $TRILINOS_INSTALL_DIR"
echo "Parallel build jobs           : $PARALLEL_JOBS"
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
# build_trilinos: build and install via CMake driver
# -----------------------------------------------------------------------------
build_trilinos() {
  cmake --build "$TRILINOS_BUILD_DIR" \
        --parallel "$PARALLEL_JOBS" \
        --target install
}

# -----------------------------------------------------------------------------
# Main entrypoint
# -----------------------------------------------------------------------------
configure_trilinos
build_trilinos

echo
echo "Trilinos has been built and installed to: $TRILINOS_INSTALL_DIR"
