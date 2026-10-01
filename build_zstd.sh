#!/bin/bash -eux

source common.sh

pushd "$BUILD_DIR"
rm -rf zstd-build
mkdir zstd-build

pushd zstd-build

# makefile can't handle parallelism
export MAKEFLAGS=""

export CFLAGS="$CFLAGS -D_POSIX_SOURCE=1"
export CXXFLAGS="$CXXFLAGS -D_POSIX_SOURCE=1"
# Static only. zstd's cmake builds BOTH by default, and libarchive's configure
# then links its test binaries against libzstd.so — which node cannot resolve at
# runtime, so every probe dies with ENOENT and configure gives up with the
# famously unhelpful "cannot compute sizeof (wchar_t)". Everything else here is
# static already; libarchive itself passes --disable-shared.
emcmake cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  -DZSTD_BUILD_SHARED=OFF \
  -DZSTD_BUILD_STATIC=ON \
  "$SOURCES_DIR/zstd/build/cmake"

emmake make
emmake make install

echo "zstd OK"
