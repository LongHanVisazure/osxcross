#!/usr/bin/env bash

pushd "${0%/*}" &>/dev/null

DESC=coreutils
USESYSTEMCOMPILER=1
source tools/tools.sh

eval $(tools/osxcross_conf.sh)

# coreutils version to build
if [ -z "$COREUTILS_VERSION" ]; then
  COREUTILS_VERSION=8.24
fi

# mirror
MIRROR="http://ftp.jaist.ac.jp/pub/GNU"

require wget

pushd $OSXCROSS_BUILD_DIR &>/dev/null

function remove_locks()
{
  rm -rf $OSXCROSS_BUILD_DIR/have_coreutils*
}

function build_and_install()
{
  if [ ! -f "have_$1_$2_${OSXCROSS_TARGET}" ]; then
    pushd $OSXCROSS_TARBALL_DIR &>/dev/null
    wget -c "$MIRROR/$1/$1-$2.tar.xz"
    popd &>/dev/null

    echo "cleaning up ..."
    rm -rf $1* 2>/dev/null

    extract "$OSXCROSS_TARBALL_DIR/$1-$2.tar.xz" 1

    pushd $1*$2* &>/dev/null
    mkdir -p build
    pushd build &>/dev/null

    ../configure \
      --target=x86_64-apple-$OSXCROSS_TARGET \
      --program-prefix=x86_64-apple-$OSXCROSS_TARGET- \
      --prefix=$OSXCROSS_TARGET_DIR/coreutils \
      --disable-nls \
      --disable-werror

    $MAKE -j$JOBS
    $MAKE install

    popd &>/dev/null
    popd &>/dev/null
    touch "have_$1_$2_${OSXCROSS_TARGET}"
  fi
}

source $BASE_DIR/tools/trap_exit.sh

build_and_install coreutils $COREUTILS_VERSION

echo ""
echo "installed coreutils to $OSXCROSS_TARGET_DIR/coreutils"
echo ""
