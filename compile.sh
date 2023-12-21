#!/bin/bash
set -x
mkdir -p /tmp # for mingw32/MSys
SCRIPTDIR="$PWD" # $(dirname $(realpath ${BASH_SOURCE[0]}))
cygpath --help >/dev/null 2>&1 && SCRIPTDIR=$(cygpath -m $SCRIPTDIR) ||:
SRCDIR="$2"

# make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" EnvironmentMessage
cp kernel_cfg.c "$SRCDIR"
cp kernel_id.h "$SRCDIR"
make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" clean
# make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" LIBS_ROOT=$(pwd)/gnuarm/arm-none-eabi all "$@"
# make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" SYSROOT=/home/maria/Code/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi all "$@"
make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" all "$@"

echo "Finished compiling NXT program"
