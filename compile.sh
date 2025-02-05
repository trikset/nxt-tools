#!/bin/bash
set -xue
SRCDIR="$2"
mkdir -p /tmp # for mingw32/MSys
SCRIPTDIR="$PWD" # $(dirname $(realpath ${BASH_SOURCE[0]}))
cygpath --help >/dev/null 2>&1 && SCRIPTDIR=$(cygpath -m $SCRIPTDIR) ||:

make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" clean
make -C "$SRCDIR" SHELL=bash NXT_TOOLS_DIR_POSIX="$SCRIPTDIR" all "$@"

echo "Finished compiling NXT program"
	
