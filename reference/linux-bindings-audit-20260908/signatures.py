#!/usr/bin/env python3
"""Compare Factor ABI signatures with the installed Linux C headers.

Generated probes live in the supplied output directory, not the source tree.
Pointer pointee types/const qualifiers are deliberately not considered ABI
differences; structure layouts and output-buffer contracts need separate checks.
"""
import argparse
import json
import pathlib
import re
import subprocess

CORE = [
    "basis/unix/ffi/ffi.factor", "basis/unix/ffi/linux/linux.factor",
    "basis/unix/process/process.factor", "basis/unix/time/time.factor",
    "basis/unix/linux/epoll/epoll.factor", "basis/unix/linux/inotify/inotify.factor",
    "basis/unix/statfs/linux/linux.factor", "basis/unix/statvfs/linux/linux.factor",
    "basis/unix/utmpx/utmpx.factor", "basis/unix/scheduler/linux/linux.factor",
    "basis/alien/libraries/unix/unix.factor", "basis/libc/libc.factor",
    "basis/libc/linux/linux.factor",
    "extra/io/serial/linux/ffi/ffi.factor", "extra/libudev/libudev.factor",
    "basis/x11/xlib/xlib.factor", "basis/x11/xim/xim.factor",
    "basis/x11/xinput2/ffi/ffi.factor",
]
HEADERS = "unistd.h stdlib.h stdio.h string.h fcntl.h dirent.h grp.h pwd.h netdb.h signal.h spawn.h sched.h time.h utime.h utmpx.h dlfcn.h locale.h sys/types.h sys/socket.h sys/file.h sys/ioctl.h sys/mman.h sys/resource.h sys/time.h sys/epoll.h sys/inotify.h sys/stat.h sys/statfs.h sys/statvfs.h sys/sendfile.h sys/wait.h sys/uio.h arpa/inet.h"
# Existing Factor APIs deliberately discard these C return values. Accept
# only that difference, never an argument, variadic or width discrepancy.
DISCARDED_RETURNS = {
    ("libc", "memset"), ("libc", "memcpy"), ("libc", "memmove"),
    ("libudev", "udev_unref"), ("libudev", "udev_device_unref"),
    ("libudev", "udev_monitor_unref"), ("libudev", "udev_enumerate_unref"),
    ("libudev", "udev_queue_unref"), ("x11.xlib", "XFree"),
}
CPP = r'''
#include <iostream>
#include <type_traits>
template<class T> void type() {
 if constexpr (std::is_void_v<T>) std::cout << "v0";
 else if constexpr (std::is_pointer_v<T>) std::cout << "p" << sizeof(T);
 else if constexpr (std::is_enum_v<T>) type<std::underlying_type_t<T>>();
 else if constexpr (std::is_floating_point_v<T>) std::cout << "f" << sizeof(T);
 else if constexpr (std::is_integral_v<T>) std::cout << (std::is_signed_v<T> ? "i" : "u") << sizeof(T);
 else std::cout << "s" << sizeof(T);
}
template<class T> struct fn;
template<class R, class... A> struct fn<R(*)(A...)> {
 static void print(const char* name) {
  std::cout << name << "\t0\t"; type<R>();
  ((std::cout << ",", type<A>()), ...); std::cout << "\n";
 }
};
template<class R, class... A> struct fn<R(*)(A..., ...)> {
 static void print(const char* name) {
  std::cout << name << "\t1\t"; type<R>();
  ((std::cout << ",", type<A>()), ...); std::cout << "\n";
 }
};
template<class R, class... A> struct fn<R(*)(A...) noexcept> : fn<R(*)(A...)> {};
template<class R, class... A> struct fn<R(*)(A..., ...) noexcept> : fn<R(*)(A..., ...)> {};
'''
FACTOR = r'''
USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh "compiler" refresh "cpu" refresh
   "unix" refresh "libc" refresh "x11.syntax" reload >>
USING: accessors alien alien.c-types alien.parser arrays classes classes.algebra
combinators io json kernel layouts locals math math.parser namespaces
parser sequences strings vocabs vocabs.loader words ;
FROM: math => float ;
IN: linux-bindings.signatures
auto-use? off
: abi-type ( type -- string )
    dup void? [ drop "v0" ] [
        base-type
        dup array? over pointer? or [ drop "p" cell ] [
            dup c-type-boxed-class float class<= [ "f" ] [
                dup c-type-boxed-class integer class<= [
                    dup c-type-signed "i" "u" ?
                ] [ dup c-type-boxed-class c-ptr class<= "p" "s" ? ] if
            ] if swap heap-size
        ] if number>string append
    ] if ;
:: signature ( vocab name -- row )
    name vocab lookup-word def>> :> definition
    definition fourth :> args
    definition 4 swap nth :> variadic
    variadic [ args variadic head ] [ args ] if [ abi-type ] map
    definition first dup wrapper? [ wrapped>> ] when abi-type prefix
    variadic >boolean name -rot 3array ;
'''

def declarations(root):
    entries = []
    for file in CORE:
        source = (root / file).read_text()
        vocab = re.search(r"IN:\s+(\S+)", source)[1]
        source = re.sub(r"!.*", "", source)
        # Separate patterns avoid treating a normal return type as an alias.
        for alias, pattern in [(False, r"FUNCTION:\s+\S+\s+(\w+)\s*\([^)]*\)"),
                               (True, r"FUNCTION-ALIAS:\s+(\S+)\s+\S+\s+(\w+)\s*\([^)]*\)")]:
            for m in re.finditer(pattern, source):
                word, symbol = (m[1], m[2]) if alias else (m[1], m[1])
                entries.append((vocab, word, symbol, file))
    return list(dict.fromkeys(entries))

def main():
    p = argparse.ArgumentParser()
    p.add_argument("root", type=pathlib.Path)
    p.add_argument("output", type=pathlib.Path)
    args = p.parse_args()
    root, out = args.root.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    includes = "#define _GNU_SOURCE 1\n" + "".join(f"#include <{h}>\n" for h in (HEADERS + " termios.h libudev.h X11/Xlib.h X11/Xutil.h X11/Xresource.h X11/Xatom.h X11/XKBlib.h X11/extensions/XInput2.h").split())
    headers = subprocess.run(["c++", "-E", "-x", "c++", "-"], input=includes, text=True, capture_output=True, check=True).stdout
    entries = declarations(root)
    available = [e for e in entries if re.search(r"\b" + re.escape(e[2]) + r"\s*\(", headers)]
    missing = [e for e in entries if e not in available]
    symbols = sorted({e[2] for e in available})
    source = includes + CPP + "int main() {\n" + "".join(f'fn<decltype(&{s})>::print("{s}");\n' for s in symbols) + "}\n"
    (out / "signatures.cpp").write_text(source)
    subprocess.run(["c++", "-std=c++17", "-Wno-deprecated-declarations", "-Wno-ignored-attributes", str(out / "signatures.cpp"), "-o", str(out / "signatures")], check=True)
    native = subprocess.check_output([str(out / "signatures")], text=True)
    (out / "native.tsv").write_text(native)
    vocabs = sorted({e[0] for e in available})
    factor = FACTOR + "\n{ " + " ".join(json.dumps(v) for v in vocabs) + " } [ require ] each\n"
    for vocab, word, symbol, file in available:
        factor += f'{json.dumps(vocab)} {json.dumps(word)} signature >json print\n'
    (out / "signatures.factor").write_text(factor)
    result = subprocess.run([str(root / "factor"), "-q", "-no-user-init", str(out / "signatures.factor")], cwd=root, text=True, capture_output=True)
    (out / "factor.log").write_text(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit(f"Factor probe failed; see {out / 'factor.log'}")
    c = {name: (flag == "1", types.split(",")) for name, flag, types in (line.split("\t") for line in native.splitlines())}
    rows = [json.loads(line) for line in result.stdout.splitlines() if line.startswith("[")]
    mismatches, adapters = [], []
    for entry, row in zip(available, rows, strict=True):
        vocab, word, symbol, file = entry
        name, types, variadic = row
        assert name == word
        if (variadic, types) != c[symbol]:
            row = {"vocab": vocab, "word": word, "symbol": symbol, "factor": [variadic, types], "native": c[symbol], "file": file}
            discarded = (vocab, word) in DISCARDED_RETURNS and types[0] == "v0" and (variadic, types[1:]) == (c[symbol][0], c[symbol][1][1:])
            (adapters if discarded else mismatches).append(row)
    report = {"checked": len(rows), "mismatches": mismatches, "discarded_return_adapters": adapters, "not_in_headers": missing}
    (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(mismatches))

if __name__ == "__main__":
    main()
