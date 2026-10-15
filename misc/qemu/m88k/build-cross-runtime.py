#!/usr/bin/env python3
"""Replay configured runtime compile commands into a fresh producer directory.

A rebuilt cross compiler is not a Ninja dependency of cached runtime objects.
Replaying each command prevents a mixture of producer revisions, while keeping
older objects and archives available for native negative controls.
"""
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile

assets = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
build = assets / "libcxx-build"
compiler = assets / "llvm-build/bin/clang++"
nice = os.environ.get("M88K_BUILD_NICE", "5")
cpp_names = """exception stdexcept typeinfo new_handler new_helpers hash memory
string system_error error_category vector condition_variable
condition_variable_destructor mutex mutex_destructor thread ios
ios.instantiations iostream locale ostream call_once""".split()
abi_prefix = "libcxxabi/src/CMakeFiles/cxxabi_static_objects.dir/"
# Query configured targets, not cached object files: this also works before
# the first libc++abi build.
configured_targets = subprocess.check_output(
    ["ninja", "-C", str(build), "-t", "targets", "all"], text=True
).splitlines()
abi_sources = sorted(
    build / line.split(": ", 1)[0]
    for line in configured_targets
    if line.startswith(abi_prefix) and line.split(": ", 1)[0].endswith(".cpp.o")
)
if len(abi_sources) != 18:
    raise SystemExit("Expected the configured pinned libc++abi's 18 translation units")


def compile_target(target, directory):
    command = subprocess.check_output(
        ["ninja", "-C", str(build), "-t", "commands", target], text=True
    ).splitlines()[-1]
    args = shlex.split(command)
    if Path(args[0]).resolve() != compiler.resolve():
        raise SystemExit("Runtime command does not use the pinned cross compiler")
    rewritten = []
    index = 0
    while index < len(args):
        option = args[index]
        if option in ("-MT", "-MF"):
            index += 2
            continue
        if option == "-MD":
            index += 1
            continue
        if option == "-o":
            rewritten.extend(("-o", str(directory / Path(target).name)))
            index += 2
            continue
        rewritten.append(option)
        index += 1
    if "-verify-machineinstrs" not in rewritten:
        raise SystemExit("Runtime command must enable the machine verifier")
    subprocess.run(["nice", "-n", nice] + rewritten, cwd=build, check=True)


cpp_output = output / "runtime-objects"
abi_output = output / "abi-objects"
cpp_output.mkdir(parents=True, exist_ok=True)
abi_output.mkdir(parents=True, exist_ok=True)
for name in cpp_names:
    compile_target("libcxx/src/CMakeFiles/cxx_static.dir/" + name + ".cpp.o", cpp_output)
for source in abi_sources:
    compile_target(str(source.relative_to(build)), abi_output)
archiver = shlex.split(os.environ.get("M88K_AR", "ar"))
archives = (
    ("libcxx-vm.a", [cpp_output / (name + ".cpp.o") for name in cpp_names]),
    ("libc++abi.a", [abi_output / source.name for source in abi_sources]),
)
for name, objects in archives:
    with tempfile.TemporaryDirectory(dir=output) as temporary:
        archive = Path(temporary) / name
        subprocess.run(
            archiver + ["rcs", str(archive)] + [str(path) for path in sorted(objects)], check=True
        )
        os.replace(archive, output / name)
