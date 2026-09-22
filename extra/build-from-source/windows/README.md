# Windows DLLs from Git

Run with Git Bash from a Visual Studio C++ developer environment:

```sh
bash extra/build-from-source/windows/build-current.sh --jobs 4
bash extra/build-from-source/windows/build-current.sh --arch x86,x64 --resume
bash extra/build-from-source/windows/build-current.sh --projects sqlite,openssl --update
bash extra/build-from-source/windows/test-driver.sh
```

Output is DLL-only `work/windows-dlls-sh/dlls/{32,64,arm64}` (x86, x64, ARM64).
Use `--work-root PATH` and `--output-root PATH` to override locations. Sources,
builds, helpers, licenses, hashes, and logs remain outside the DLL output.
Nothing is installed into Factor or uploaded; Microsoft CRTs are excluded.

## Prerequisites

Git, CMake, Ninja, MSVC, and a Windows SDK with every requested target installed.
The developer environment must set `VCToolsInstallDir`, `INCLUDE`, `LIB`, and
`VSCMD_ARG_HOST_ARCH`. The script selects target compilers and libraries.
Configuration probes and load checks execute target binaries: Windows ARM64
can build/check all three targets using emulation; use an ARM64 machine for
ARM64 builds. Consumers need the matching Microsoft runtime.

- OpenSSL: Windows Perl, NASM for x86/x64; Jom optional. Per-user Strawberry
  Perl is detected. The `openssl-3.5` branch preserves Factor's OpenSSL 3 ABI.
- Cairo: native Python and Meson; network access for fallback dependencies.
- FFTW Git bootstrap: GCC, Make, Autoconf, Automake, Libtool, OCaml, ocamlbuild,
  OCaml Num, and indent. See [upstream instructions](https://github.com/FFTW/fftw3#readme).
- LibreSSL Git bootstrap: Unix-compatible `cpp`, Perl, and tools required by
  [update.sh](https://github.com/libressl/portable), which clones OpenBSD sources.

FFTW/LibreSSL Git bootstraps are unverified here; plain Git Bash lacks their
Unix tools. The builder does not substitute release archives.

## Recipes and behavior

Default: `zlib,lz4,zstd,yaml,snappy,zeromq,pcre2,openal,raylib,raygui`.
Additional: `pcre,sqlite,openssl,cairo,openblas,forestdb,duckdb,fftw,libressl`.
Raygui requires raylib built in the same work root. PostgreSQL/libpq and udis86
are not covered; executables such as ripgrep are outside this DLL-only task.

Repositories are shallow-cloned once; only `--update` fetches new revisions.
Dirty trees and unexpected origins are rejected. PCRE's CMake patch uses a
separate prepared copy. `--resume` skips builds only when source, builder,
patch/checker fingerprints, and staged DLL hashes match.

Failures are logged per project and do not stop the matrix; any failure makes
the final exit status nonzero. `results.tsv` records the latest invocation.
Use separate work **and output** roots for concurrent runs. Remove a stale
`.build-lock` only after confirming its build has stopped.

DLL machine types and matching-architecture loads are checked before success.
Original import names are retained alongside Factor aliases. OpenBLAS is
BLAS-only (no Fortran/LAPACK); ZeroMQ uses upstream security defaults (CURVE
needs libsodium). Cairo builds dependencies pinned by its Meson wraps, not
necessarily Git HEAD. DuckDB's shell is disabled.

Zlib/libyaml, ZeroMQ, and raygui shell builds passed load checks on all three
targets, including raygui's raylib dependency. This is not full bundle or
Factor `test-all` validation. Review licenses, dependencies, APIs, and tests
before publishing; failed invocations may leave previously staged DLLs.
