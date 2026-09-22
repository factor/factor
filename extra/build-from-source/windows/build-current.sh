#!/usr/bin/env bash
# Run with Git Bash from a Visual Studio C++ developer environment.
set -Eeuo pipefail

script_path=${BASH_SOURCE[0]:-$0}
# Snapshot long builds so editing this file cannot change a running invocation.
if [[ ${FACTOR_DLL_SCRIPT_SNAPSHOT:-} != 1 ]]; then
    export FACTOR_DLL_SCRIPT_SNAPSHOT=1
    script_text=$(<"$script_path")
    FACTOR_DLL_SCRIPT_DIGEST=$(printf '%s' "$script_text" | sha256sum | cut -d ' ' -f 1)
    export FACTOR_DLL_SCRIPT_DIGEST
    exec bash -c "$script_text" "$script_path" "$@"
fi
script_dir=$(cd -- "$(dirname -- "$script_path")" && pwd)
repo_dir=$(cd -- "$script_dir/../../.." && pwd)
work_root="$repo_dir/work/windows-dlls-sh"
output_root=
architectures=(arm64 x64 x86)
projects=(zlib lz4 zstd yaml snappy zeromq pcre2 openal raylib raygui)
jobs=4
update=0
resume=0

usage() {
    cat <<'EOF'
Usage: build-current.sh [options]
  --arch arm64,x64,x86       Target architectures (default: all three)
  --projects zlib,lz4,...    Libraries to build (default: core batch)
  --work-root PATH          Separate source/build/install/stage/log directories
  --output-root PATH        DLL-only 32/, 64/, arm64/ folders (default: WORK/dlls)
  --jobs N                  Compiler parallelism (default: 4)
  --update                  Fetch upstream HEAD before building (clean trees only)
  --resume                  Skip previously verified matching builds
  --help                    Show this help

Run under Git Bash from a Visual Studio C++ developer prompt. Git, CMake,
Ninja, and a target MSVC compiler are required. Failures are logged per library;
other builds continue, and the final exit status is nonzero if any build fails.
No binaries are installed into Factor or uploaded.
EOF
}
while (($#)); do
    case "$1" in
        --arch) IFS=, read -r -a architectures <<< "${2:?missing architectures}"; shift 2 ;;
        --projects) IFS=, read -r -a projects <<< "${2:?missing projects}"; shift 2 ;;
        --work-root) work_root=${2:?missing work root}; shift 2 ;;
        --output-root) output_root=${2:?missing output root}; shift 2 ;;
        --jobs) jobs=${2:?missing jobs}; shift 2 ;;
        --update) update=1; shift ;;
        --resume) resume=1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
[[ $jobs =~ ^[1-9][0-9]*$ ]] || { echo 'Invalid --jobs' >&2; exit 2; }
for arch in "${architectures[@]}"; do
    case "$arch" in arm64|x64|x86) ;; *) echo "Invalid architecture: $arch" >&2; exit 2 ;; esac
done

recipe() {
    url= ref=HEAD subdir= type=cmake prepare=
    options=()
    case "$1" in
        zlib) url=https://github.com/madler/zlib.git; options=(-DZLIB_BUILD_TESTING=OFF) ;;
        lz4) url=https://github.com/lz4/lz4.git; subdir=build/cmake; options=(-DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF) ;;
        zstd) url=https://github.com/facebook/zstd.git; subdir=build/cmake; options=(-DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -DZSTD_BUILD_STATIC=OFF) ;;
        yaml) url=https://github.com/yaml/libyaml.git; options=(-DBUILD_TESTING=OFF) ;;
        snappy) url=https://github.com/google/snappy.git; options=(-DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF) ;;
        zeromq) url=https://github.com/zeromq/libzmq.git; options=(-DBUILD_TESTS=OFF -DZMQ_BUILD_TESTS=OFF -DBUILD_STATIC=OFF -DWITH_DOCS=OFF) ;;
        pcre2) url=https://github.com/PCRE2Project/pcre2.git; options=(-DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON -DPCRE2_BUILD_TESTS=OFF -DPCRE2_BUILD_PCRE2GREP=OFF) ;;
        openal) url=https://github.com/kcat/openal-soft.git; options=(-DALSOFT_EXAMPLES=OFF -DALSOFT_UTILS=OFF -DALSOFT_TESTS=OFF) ;;
        raylib) url=https://github.com/raysan5/raylib.git; options=(-DBUILD_EXAMPLES=OFF) ;;
        raygui) url=https://github.com/raysan5/raygui.git; type=raygui ;;
        openblas) url=https://github.com/OpenMathLib/OpenBLAS.git; options=(-DBUILD_TESTING=OFF -DNOFORTRAN=ON -DNO_LAPACK=ON) ;;
        duckdb) url=https://github.com/duckdb/duckdb.git; options=(-DBUILD_UNITTESTS=OFF -DBUILD_SHELL=OFF -DDISABLE_UNITY=ON -DENABLE_EXTENSION_AUTOLOADING=OFF -DENABLE_EXTENSION_AUTOINSTALL=OFF) ;;
        forestdb) url=https://github.com/couchbase/forestdb.git; options=(-DBUILD_TESTING=OFF) ;;
        fftw) url=https://github.com/FFTW/fftw3.git; prepare=fftw; options=(-DBUILD_TESTS=OFF) ;;
        libressl) url=https://github.com/libressl/portable.git; prepare=libressl; options=(-DLIBRESSL_APPS=OFF -DLIBRESSL_TESTS=OFF) ;;
        pcre) url=https://github.com/PCRE2Project/pcre1.git; options=(-DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON -DPCRE_BUILD_TESTS=OFF -DPCRE_BUILD_PCREGREP=OFF -DPCRE_BUILD_PCRECPP=OFF -DPCRE_REBUILD_CHARTABLES=OFF) ;;
        sqlite) url=https://github.com/sqlite/sqlite.git; type=sqlite ;;
        openssl) url=https://github.com/openssl/openssl.git; ref=openssl-3.5; type=openssl ;;
        cairo) url=https://gitlab.freedesktop.org/cairo/cairo.git; type=meson; options=(--force-fallback-for=freetype2,fontconfig,zlib,expat,expat_dep,pixman,libpng,glib,intl -Dtests=disabled -Dglib=enabled -Dfreetype=enabled -Dfontconfig=enabled -Dpng=enabled -Dzlib=enabled -Dpixman:mmx=disabled -Dpixman:sse2=disabled -Dpixman:ssse3=disabled -Dpixman:tests=disabled -Dpixman:demos=disabled -Dglib:tests=false) ;;
        *) echo "No recipe for $1" >&2; return 2 ;;
    esac
}
for project in "${projects[@]}"; do recipe "$project"; done
command -v cygpath >/dev/null || { echo 'Use Git Bash on Windows' >&2; exit 2; }
for tool in git cmake ninja; do command -v "$tool" >/dev/null || { echo "Missing tool: $tool" >&2; exit 2; }; done
: "${VCToolsInstallDir:?Run from a Visual Studio C++ developer environment}"
: "${INCLUDE:?Missing compiler INCLUDE environment}"
: "${LIB:?Missing compiler LIB environment}"
export GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=Never
export MSYS2_ARG_CONV_EXCL='*'
work_root=$(cygpath -au "$work_root")
output_root=$(cygpath -au "${output_root:-$work_root/dlls}")
mkdir -p "$work_root"/{sources,build,install,logs,state,licenses}
mkdir -p "$output_root"/{32,64,arm64}
# Never remove another process's lock.
mkdir "$work_root/.build-lock" 2>/dev/null || { echo "Work root is locked: $work_root" >&2; exit 2; }
printf '%s\n' "$$" > "$work_root/.build-lock/pid"
trap 'rm -f -- "$work_root/.build-lock/pid"; rmdir -- "$work_root/.build-lock"' EXIT

vc_tools=$(cygpath -au "$VCToolsInstallDir")
host_arch=${VSCMD_ARG_HOST_ARCH:-arm64}
base_path=$PATH
# OpenSSL requires Windows Perl, not Git Bash's Perl.
if [[ -n ${LOCALAPPDATA:-} ]]; then
    local_apps=$(cygpath -au "$LOCALAPPDATA")
    for perl_bin in "$local_apps"/Programs/StrawberryPerl*/perl/bin /c/Strawberry/perl/bin; do
        [[ ! -x $perl_bin/perl.exe ]] || base_path="$perl_bin:$base_path"
    done
fi
base_lib=$LIB
base_libpath=${LIBPATH:-}
export CC=cl CXX=cl
status_file="$work_root/results.tsv"
printf 'architecture\tproject\tcommit\tstatus\tlog\n' > "$status_file"

checkout() {
    local source=$1
    local git_source
    git_source=$(cygpath -am "$source")
    if [[ ! -d $source/.git ]]; then
        [[ ! -e $source ]] || { echo "Not a Git checkout: $source" >&2; return 1; }
        local clone_options=(--depth 1)
        [[ $ref == HEAD ]] || clone_options+=(--branch "$ref")
        git clone "${clone_options[@]}" "$url" "$git_source"
    fi
    [[ $(git -C "$git_source" remote get-url origin) == "$url" ]] || { echo 'Unexpected source origin' >&2; return 1; }
    [[ -z $(git -C "$git_source" status --porcelain) ]] || { echo "Dirty source checkout: $source" >&2; return 1; }
    if ((update)); then
        git -C "$git_source" fetch --depth 1 origin "$ref"
        git -C "$git_source" checkout --detach FETCH_HEAD
    fi
    git -C "$git_source" rev-parse HEAD
}

build_one() (
    # Keep errexit while the parent collects failures.
    set -Eeuo pipefail
    local arch=$1 project=$2
    recipe "$project"
    local compiler="$vc_tools/bin/Host$host_arch/$arch"
    [[ -x $compiler/cl.exe ]] || { echo "Missing compiler: $compiler" >&2; exit 1; }
    export PATH="$compiler:$base_path"
    export LIB LIBPATH VSCMD_ARG_TGT_ARCH="$arch"
    LIB=$(printf '%s' "$base_lib" | sed -E "s@([\\\\/])(arm64|ARM64|x64|X64|x86|X86)([\\\\/;]|$)@\\1$arch\\3@g")
    LIBPATH=$(printf '%s' "$base_libpath" | sed -E "s@([\\\\/])(arm64|ARM64|x64|X64|x86|X86)([\\\\/;]|$)@\\1$arch\\3@g")
    local source="$work_root/sources/$project"
    local build="$work_root/build/$arch/$project"
    local install="$work_root/install/$arch/$project"
    local output_arch
    case "$arch" in x86) output_arch=32 ;; x64) output_arch=64 ;; arm64) output_arch=arm64 ;; esac
    local stage="$output_root/$output_arch"
    local stamp="$work_root/state/$arch-$project"
    checkout "$source"
    local commit
    commit=$(git -C "$(cygpath -am "$source")" rev-parse HEAD)
    printf '%s\n' "$commit" > "$stamp.commit"
    local build_key="$commit:${FACTOR_DLL_SCRIPT_DIGEST:?missing script digest}"
    local patch_digest
    patch_digest=$(sha256sum "$script_dir/check-dll.c" "$script_dir"/patches/* | sha256sum | cut -d ' ' -f 1)
    build_key+=":$patch_digest"
    if [[ $project == raygui && -d $work_root/sources/raylib/.git ]]; then
        build_key+=":$(git -C "$(cygpath -am "$work_root/sources/raylib")" rev-parse HEAD)"
    fi
    if ((resume)) && [[ -f $stamp.sha256 && -f $stamp.built ]] && [[ $(<"$stamp.built") == "$build_key" ]]; then
        if (cd "$stage" && sha256sum -c "$stamp.sha256"); then
            echo "Already verified: $arch $project $commit"
            exit 0
        fi
    fi
    mkdir -p "$build" "$install/bin" "$stage"
    if [[ -n $prepare ]]; then
        local prepared="$work_root/prepared/$project-$commit"
        if [[ ! -f $prepared/.factor-prepared ]]; then
            [[ -d $prepared ]] || git -C "$(cygpath -am "$source")" worktree add --detach "$(cygpath -am "$prepared")" "$commit"
            case "$prepare" in
                fftw)
                    for tool in autoreconf make ocaml ocamlbuild indent gcc; do
                        command -v "$tool" >/dev/null || { echo "FFTW Git code generation requires host tool: $tool" >&2; exit 1; }
                    done
                    (cd "$prepared"; unset MSYS2_ARG_CONV_EXCL; export PATH="/usr/bin:$PATH" CC=gcc CXX=g++
                        sh bootstrap.sh --disable-doc; make -j "$jobs")
                    ;;
                libressl)
                    command -v cpp >/dev/null || { echo 'LibreSSL Git bootstrap requires a host C preprocessor (cpp)' >&2; exit 1; }
                    (cd "$prepared"; unset MSYS2_ARG_CONV_EXCL; export PATH="/usr/bin:$PATH"; sh update.sh)
                    git -C "$(cygpath -am "$prepared/openbsd")" rev-parse HEAD > "$stamp.openbsd-commit"
                    ;;
            esac
            touch "$prepared/.factor-prepared"
        fi
        source=$prepared
    fi
    if [[ $project == pcre ]]; then
        local patched="$work_root/prepared/pcre-$commit"
        if [[ ! -f $patched/.factor-patched ]] || [[ $(<"$patched/.factor-patched") != "$patch_digest" ]]; then
            mkdir -p "$patched"
            git -C "$(cygpath -am "$source")" archive HEAD | tar -xf - -C "$patched"
            # Prevent git apply from silently skipping paths in the parent repo.
            git init "$(cygpath -am "$patched")"
            (cd "$patched" && git apply "$(cygpath -am "$script_dir/patches/pcre-cmake4.patch")")
            printf '%s\n' "$patch_digest" > "$patched/.factor-patched"
        fi
        source=$patched
    fi
    local source_win build_win install_win
    source_win=$(cygpath -am "$source${subdir:+/$subdir}")
    build_win=$(cygpath -am "$build")
    install_win=$(cygpath -am "$install")
    case "$type" in
        cmake)
            if [[ $project == openblas ]]; then
                options+=(-DCMAKE_SYSTEM_NAME=Windows)
                case "$arch" in
                    arm64) options+=(-DTARGET=ARMV8 -DCMAKE_SYSTEM_PROCESSOR=ARM64 -DBINARY=64) ;;
                    x64) options+=(-DTARGET=NEHALEM -DCMAKE_SYSTEM_PROCESSOR=AMD64 -DBINARY=64) ;;
                    x86) options+=(-DTARGET=NEHALEM -DCMAKE_SYSTEM_PROCESSOR=x86 -DBINARY=32) ;;
                esac
            fi
            cmake -S "$source_win" -B "$build_win" -G Ninja \
                -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
                -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE \
                "-DCMAKE_C_COMPILER=$(cygpath -am "$compiler/cl.exe")" \
                "-DCMAKE_CXX_COMPILER=$(cygpath -am "$compiler/cl.exe")" \
                "-DCMAKE_INSTALL_PREFIX=$install_win" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 "${options[@]}"
            if [[ $project == forestdb ]]; then
                # Exclude upstream's broken endurance tests.
                cmake --build "$build_win" --parallel "$jobs" --target forestdb
                cp "$build/forestdb.dll" "$install/bin/"
            else
                cmake --build "$build_win" --parallel "$jobs"
                cmake --install "$build_win"
            fi
            ;;
        raygui)
            local raylib="$work_root/install/$arch/raylib"
            [[ -f $raylib/lib/raylib.lib ]] || { echo 'Build raylib first in this work root' >&2; exit 1; }
            cp "$source/src/raygui.h" "$build/raygui.c"
            (cd "$build" && cl /nologo /O2 /MD /LD /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED \
                "/I$(cygpath -am "$raylib/include")" raygui.c /link \
                "$(cygpath -am "$raylib/lib/raylib.lib")" "/OUT:$install_win/bin/raygui.dll" "/MACHINE:$arch")
            ;;
        sqlite)
            # Makefile.msc's COPY commands require backslashes.
            local sqlite_top
            sqlite_top=$(cygpath -aw "$source")
            (cd "$build" && nmake /nologo /f "$sqlite_top\Makefile.msc" "TOP=$sqlite_top" sqlite3.dll)
            cp "$build/sqlite3.dll" "$install/bin/"
            ;;
        openssl)
            perl -e 'exit($^O eq "MSWin32" ? 0 : 1)' || { echo 'Windows Perl required' >&2; exit 1; }
            local target suffix
            case "$arch" in
                arm64) target=VC-WIN64-ARM; suffix=-arm64 ;;
                x64) target=VC-WIN64A; suffix=-x64; command -v nasm >/dev/null ;;
                x86) target=VC-WIN32; suffix=; command -v nasm >/dev/null ;;
            esac
            (
                cd "$build"
                export LC_ALL=C LANG=C
                perl "$source_win/Configure" "$target" shared no-tests /FS
                nmake /nologo build_generated
                if command -v jom >/dev/null; then
                    jom -j "$jobs" "libssl-3$suffix.dll" || nmake /nologo "libssl-3$suffix.dll"
                else
                    nmake /nologo "libssl-3$suffix.dll"
                fi
            )
            cp "$build/libssl-3$suffix.dll" "$build/libcrypto-3$suffix.dll" "$install/bin/"
            ;;
        meson)
            command -v meson >/dev/null
            local configured=0
            for attempt in 1 2 3; do
                if meson setup --reconfigure "$build_win" "$source_win" --buildtype=release --default-library=shared \
                    "--prefix=$install_win" "${options[@]}"; then configured=1; break; fi
                sleep "$attempt"
            done
            ((configured)) || exit 1
            meson compile -C "$build_win" -j "$jobs"
            meson install -C "$build_win" --no-rebuild
            ;;
    esac
    local checker="$build/check-dll.exe" dll name expected
    local dlls=() names=()
    case "$arch" in arm64) expected=AA64 ;; x64) expected=8664 ;; x86) expected=14C ;; esac
    (cd "$build" && cl /nologo /O2 /MT "$(cygpath -am "$script_dir/check-dll.c")" \
        "/Fe:$(cygpath -am "$checker")" "/Fo:$build_win/check-dll.obj" /link "/MACHINE:$arch")
    # Exclude redistributable CRTs, including host/ARM64EC copies.
    project_dlls() {
        find "$install" -type f -iname '*.dll' \
            ! -iname 'msvcp*.dll' ! -iname 'vcruntime*.dll' \
            ! -iname 'concrt*.dll' ! -iname 'ucrtbase.dll' \
            ! -iname 'api-ms-win-*.dll' -print0
        if [[ $project == raygui ]]; then
            # Include raylib even when staging to a new output root.
            find "$work_root/install/$arch/raylib" -type f -iname 'raylib.dll' -print0
        fi
    }
    mapfile -d '' -t dlls < <(project_dlls)
    ((${#dlls[@]})) || { echo 'No DLLs were installed' >&2; exit 1; }
    for dll in "${dlls[@]}"; do
        dumpbin /headers "$(cygpath -am "$dll")" | grep -Ei "[[:space:]]$expected machine" >/dev/null || { echo "Wrong machine: $dll" >&2; exit 1; }
        cp "$dll" "$stage/"
        names+=("${dll##*/}")
    done
    alias_dll() { cp "$1" "$stage/$2"; names+=("$2"); }
    # Preserve upstream import names alongside Factor aliases.
    case "$project" in
        zlib) if [[ -f $stage/libz.dll ]]; then alias_dll "$stage/libz.dll" zlib1.dll; fi ;;
        zstd) if [[ -f $stage/zstd.dll ]]; then alias_dll "$stage/zstd.dll" zstd-1.dll; fi ;;
        libressl)
            for name in crypto ssl tls; do
                [[ -f $install/bin/$name.dll ]] || { echo "Missing LibreSSL DLL: $name" >&2; exit 1; }
                alias_dll "$install/bin/$name.dll" "libressl-$name.dll"
            done
            ;;
        zeromq|openblas)
            local alias
            ((${#dlls[@]} == 1)) || { echo 'Ambiguous primary DLL' >&2; exit 1; }
            if [[ $project == zeromq ]]; then alias=libzmq.dll; else alias=blas.dll; fi
            alias_dll "${dlls[0]}" "$alias"
            ;;
    esac
    : > "$stamp.sha256"
    for name in "${names[@]}"; do
        # Native backslashes are required for sibling DLL lookup.
        "$checker" "$(cygpath -aw "$stage/$name")"
        (cd "$stage" && sha256sum "$name") >> "$stamp.sha256"
    done
    mkdir -p "$work_root/licenses/$project"
    find "$source" -maxdepth 1 -type f \( -iname 'LICENSE*' -o -iname 'COPYING*' -o -iname 'COPYRIGHT*' \) -exec cp '{}' "$work_root/licenses/$project/" \;
    printf '%s\n' "$build_key" > "$stamp.built"
)

failed=0
for arch in "${architectures[@]}"; do
    for project in "${projects[@]}"; do
        log="$work_root/logs/$arch-$project.log"
        echo "BUILD $arch $project (log: $log)"
        set +e
        build_one "$arch" "$project" > "$log" 2>&1
        code=$?
        set -e
        commit=unknown
        [[ ! -f $work_root/state/$arch-$project.commit ]] || commit=$(<"$work_root/state/$arch-$project.commit")
        if ((code == 0)); then status=passed; else status=failed; failed=$((failed+1)); fi
        printf '%s\t%s\t%s\t%s\t%s\n' "$arch" "$project" "$commit" "$status" "$log" >> "$status_file"
        echo "$status $arch $project"
        if ((code)); then tail -n 12 "$log"; fi
    done
done
echo "Results: $status_file; failures: $failed"
((failed == 0))
