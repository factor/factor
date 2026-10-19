#!/bin/sh
# Execute inside an OpenBSD/luna88k guest with the comp set installed.
set -eu
case "$(uname -s):$(uname -m)" in
    OpenBSD:luna88k) ;;
    *) echo 'This gate requires a native OpenBSD/luna88k guest.' >&2; exit 2 ;;
esac
cd "$(dirname "$0")"
${CC:-cc} -O2 -fPIC -shared native-ffi.c -o libnative-ffi.so
${CC:-cc} -O2 -Wall -Wextra native-probe.c "${M88K_CODE_OBJECT:-native-code.S}" -o native-probe
./native-probe
${CXX:-c++} -std=c++98 -O2 native-cxx-runtime.cpp -o native-cxx-runtime
./native-cxx-runtime
