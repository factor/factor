# Factor

![Build](https://github.com/factor/factor/actions/workflows/build.yml/badge.svg)
[![Release](https://img.shields.io/github/v/release/factor/factor?label=Release)](https://github.com/factor/factor/releases)

Factor is a [concatenative](https://www.concatenative.org), stack-based
programming language with [high-level
features](https://concatenative.org/wiki/view/Factor/Features/The%20language)
including dynamic types, extensible syntax, macros, and garbage collection.
On a practical side, Factor has a [full-featured
library](https://docs.factorcode.org/content/article-vocab-index.html),
supports many different platforms, and has been extensively documented.

The implementation is [fully
compiled](https://concatenative.org/wiki/view/Factor/Optimizing%20compiler)
for performance, while still supporting [interactive
development](https://concatenative.org/wiki/view/Factor/Interactive%20development).
Factor applications are portable between all common platforms.  Factor can
[deploy stand-alone
applications](https://concatenative.org/wiki/view/Factor/Deployment) on all
platforms.  Full source code for the Factor project is available under a BSD
license.

## Getting Started

### Building Factor from source

If you have a build environment set up, then you can build Factor from git.
These scripts will attempt to compile the Factor binary and bootstrap from
a boot image stored on factorcode.org.

To check out Factor:

* git clone https://github.com/factor/factor.git
* `cd factor`

To build the latest complete Factor system from git, either use the
build script:

* Unix: `./build.sh update`
* Windows: `build.cmd`
* M1 macOS: `arch -x86_64 ./build.sh update`

or download the correct boot image for your system from
https://downloads.factorcode.org/images/master/, put it in the `factor`
directory and run:

* Unix: `make` and then `./factor -i=boot.unix-x86.64.image`
* Windows: `nmake /f Nmakefile` and then `factor.com -i=boot.windows-x86.64.image` or `factor.com -i=boot.windows-arm.64.image` for ARM64

Now you should have a complete Factor system ready to run.

The ARM64 assembler and compiler backend are in `cpu.arm.64`. RISC-V Linux
development targets RV64GC with the LP64D ABI and RV32GC with the ILP32D ABI.
Their assemblers and compiler backends are in `cpu.riscv.64` and `cpu.riscv.32`.

To create a RISC-V seed image, run this in a working Factor checkout:

```bash
./factor -no-user-init -e='USING: bootstrap.image ; "unix-riscv.64" make-image'
```

Copy `boot.unix-riscv.64.image` into the RISC-V checkout. On a Debian
`riscv64` system, including a QEMU system guest, build and bootstrap with:

```bash
sudo apt-get update
./build.sh deps-apt
CC=gcc CXX=g++ ./build.sh compile
./factor -i="$PWD/boot.unix-riscv.64.image" -no-user-init -output-image=factor.image
```

To validate the compiler and I/O vocabularies after bootstrap:

```bash
./build.sh deps-apt-tests
./factor -i="$PWD/factor.image" -no-user-init -run=tools.test compiler io
```

For the complete vocabulary suite, keep PostgreSQL and Redis running in the
test environment. PostgreSQL's local login role needs permission to create
databases; the tests use a database name that includes the CPU architecture.
Redis tests clear database 0, so use a dedicated test instance. For a fresh
Debian test guest:

```bash
sudo -u postgres createuser --createdb "$(id -un)"
xvfb-run -a ./factor -i="$PWD/factor.image" -no-user-init -e='USING: assocs compiler.errors db.postgresql io kernel math namespaces prettyprint sequences system tools.test vocabs.hierarchy ; <postgresql-db> \ postgresql-db set-global load-all test-all :test-failures compiler-errors get assoc-size . test-failures get length compiler-errors get assoc-size + zero? [ 0 ] [ 1 ] if exit'
```

The legacy `pcre` vocabulary also needs PCRE1. On Debian releases without its
package, build the shared PCRE 8.45 library with `--enable-utf` and
`--enable-unicode-properties` and run `ldconfig` after installing it. The RV32
environment script builds this library automatically. Use GCC for the native
FFI test library so its packed-struct fixtures match the GNU RISC-V ABI oracle.

For RV32, `misc/riscv32/build.sh` creates a Buildroot Linux environment with a
cross compiler and the runtime dependencies. Run it on a Linux builder, then
start the resulting guest with `misc/riscv32/run-qemu.sh`. Both scripts describe
their prerequisites and SSH options. Generate the seed image on the host with:

```bash
./factor -no-user-init -e='USING: bootstrap.image ; "unix-riscv.32" make-image'
```

Cross-compile the VM with the generated toolchain, copy the checkout and seed
image into the guest, then bootstrap and test there:

```bash
# On the Linux builder, in the target checkout:
CC=/absolute/path/to/rv32-output/host/bin/riscv32-buildroot-linux-gnu-gcc \
CXX=/absolute/path/to/rv32-output/host/bin/riscv32-buildroot-linux-gnu-g++ \
make linux-riscv-32
# In the RV32 guest:
./factor -i="$PWD/boot.unix-riscv.32.image" -no-user-init -output-image=factor.image
./factor -i="$PWD/factor.image" -no-user-init -run=tools.test compiler io
```

To run either target under QEMU user emulation on a Linux builder, use
`misc/riscv/test-qemu.sh`. It runs the default bootstrap, both assembler suites,
the compiler and I/O suites, standard `load-all`, and standard `test-all`.
Prepare a target root filesystem with the dependencies above, install
`qemu-user-static` on the builder, and cross-build the target executable and
GNU FFI test library in a separate checkout. RV32 can use the Buildroot
`OUTPUT_DIR/target` directory; RV64 can use a Debian riscv64 root filesystem.
Use a Git clone with history and install Git in the target root filesystem;
the contributors test reads the repository log.
The Linux kernel must support user namespaces and namespaced `binfmt_misc`.
The script uses passwordless sudo to create private mount, PID and user
namespaces, without registering a global QEMU handler.
Child Factor processes use the current stage image through a private default-image
mount beside the executable.

QEMU 10.0.13 user emulation returns `ENOTTY` for unsupported ioctl requests
before checking whether the descriptor is valid. Linux returns `EBADF` first,
which the input-event tests verify. Build the pinned static interpreters with
the included correction and select them with `--qemu`; system QEMU and native
Linux do not need this user-emulation correction.

```bash
sudo apt-get install build-essential curl xz-utils patch python3-venv \
    libglib2.0-dev zlib1g-dev pkg-config ninja-build
misc/riscv/build-qemu.sh /absolute/path/to/qemu-tools
```

```bash
# Dedicated reachable PostgreSQL and Redis instances for vocabulary tests:
export PGHOST=127.0.0.1 PGPORT=5432 PGUSER=factor_test
export PGPASSWORD='your-test-password'
export REDIS_HOST=127.0.0.1 REDIS_PORT=6380

misc/riscv/test-qemu.sh --qemu /absolute/path/to/qemu-tools/bin/qemu-riscv32 \
    32 /absolute/path/to/rv32-output/target /absolute/path/to/rv32-checkout
misc/riscv/test-qemu.sh --qemu /absolute/path/to/qemu-tools/bin/qemu-riscv64 \
    64 /absolute/path/to/debian-riscv64-root /absolute/path/to/rv64-checkout
```

The seed image defaults to `boot.unix-riscv.32.image` or
`boot.unix-riscv.64.image` in the target checkout. Results go to a timestamped
`build/riscv-qemu/` directory containing stage logs, exit codes, and verified
images. A failed stage stops the run. Resume from a successful image with
`--image FILE --stage load-all` or `--image FILE --stage test-all`;
when restoring a loaded image for `test-all`, also pass `--gui-image FILE`
with a clean, current bootstrap image for GUI and exit-test child processes.
The default `all` run provides its fresh bootstrap image automatically.
`--stage bootstrap`, `--stage prefixes`, and `--stage probe` run individual
checks. `--stage essentials` loads and tests every `core/` vocabulary and the
full compiler, I/O, and UI prefixes. `--output DIR` selects a results directory inside the target checkout,
and `--vm factor-zig32-release` selects another target executable. Run the two
widths sequentially when they share a Redis test instance or network namespace;
some I/O tests bind fixed ports.
Validation failures also save a separate `.failed.image` for diagnosis and
recovery after fixing the source; it does not count as a successful stage.

More information on [building factor](https://concatenative.org/wiki/view/Factor/Building%20Factor)
and [system requirements](https://concatenative.org/wiki/view/Factor/Requirements).

The experimental Zig VM requires Zig 0.17.0. Use `zig build` to build it and
`zig build test` to run its native tests. RISC-V cross-builds must select the
RVGC instruction extensions; for example:

```bash
zig build -Dtarget=riscv64-linux-gnu -Dcpu=generic_rv64+m+a+f+d+c
```

To compile the VM and tests for
Windows without running them, use `zig build check -Dtarget=x86_64-windows-gnu`
or `zig build check -Dtarget=aarch64-windows-gnu`. On Windows,
`zig build test-process-wait` runs the process notification tests separately.

### To run a Factor binary:

You can download a Factor binary from the grid on [https://factorcode.org](https://factorcode.org).
The nightly builds are usually a better experience than the point releases.

* Windows: Double-click `factor.exe`, or run `.\factor.com` in a command prompt
* macOS: Double-click `Factor.app` or run `open Factor.app` in a Terminal
* Unix: Run `./factor` in a shell

#### Linux GUI requirements

##### Stable release (GTK2 + gtkglext)

The current stable version of Factor uses GTK2 and `gtkglext`.  
On Debian 13 “Trixie” and newer Ubuntu releases (25.10 “Questing Quokka” and the 26.04 “Resolute Raccoon” development branch), the `gtkglext` library is no longer available in the official repositories.

Factor's GUI depends on this library, so a fresh install cannot start the GUI on these systems.

---

###### Debian workaround:

You can manually install the legacy Debian package and add symbolic links:

```bash
wget -c http://http.us.debian.org/debian/pool/main/g/gtkglext/libgtkglext1_1.2.0-11_amd64.deb
sudo apt install ./libgtkglext1_1.2.0-11_amd64.deb

sudo ln -s /usr/lib/x86_64-linux-gnu/libgtkglext-x11-1.0.so.0 \
           /usr/lib/x86_64-linux-gnu/libgtkglext-x11-1.0.so

sudo ln -s /usr/lib/x86_64-linux-gnu/libgdkglext-x11-1.0.so.0 \
           /usr/lib/x86_64-linux-gnu/libgdkglext-x11-1.0.so
```

This workaround has been tested in clean containers for:

* Debian 13

---

###### Ubuntu workaround:

You can install the `libgtkglext1` `.deb` package from a previous Ubuntu release (e.g. 25.04 “Plucky Pangolin”)
and manually add symbolic links expected by Factor:

```bash
# Install .deb from Ubuntu 25.04:
wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkglext/libgtkglext1_1.2.0-11_amd64.deb
sudo apt install ./libgtkglext1_1.2.0-11_amd64.deb

# Add missing symlinks manually:
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libgtkglext-x11-1.0.so.0.0.0 libgtkglext-x11-1.0.so
sudo ln -s libgdkglext-x11-1.0.so.0.0.0 libgdkglext-x11-1.0.so
```

This workaround has been tested in clean containers for:

* Ubuntu 25.10
* Ubuntu 26.04 (development branch)

---

On Debian 12, Ubuntu 22.04, 24.04 and 25.04 `libgtkglext1` is still available in the repositories and no workaround is required.

##### Development branch (GTK4, with GTK3 available)

The development branch uses GTK4 by default. Install GTK4 and libepoxy:

* Debian/Ubuntu: `sudo apt install libgtk-4-1 libepoxy0`
* Fedora: `sudo dnf install gtk4 libepoxy`
* Arch: `sudo pacman -S gtk4 libepoxy`

On FreeBSD, install `gtk4` and `libepoxy`. GTK4 supports both X11 and
Wayland; `GDK_BACKEND=x11` or `GDK_BACKEND=wayland` selects the display
backend. Other UI dependencies, including Pango and GdkPixbuf, are unchanged.

GTK3 remains supported. **Choose the GTK version when bootstrapping an
image**, since GTK3 and GTK4 cannot be loaded into the same process. For
example, on Linux x86-64, build both images from the matching boot image:

```bash
# Default: GTK4
./factor -i=boot.unix-x86.64.image

# Explicit choices, using that same boot image:
./factor -i=boot.unix-x86.64.image -ui-backend=gtk4 -output-image=factor-gtk4.image
./factor -i=boot.unix-x86.64.image -ui-backend=gtk3 -output-image=factor-gtk3.image
```

The build script accepts both explicit choices:
`./build.sh bootstrap -ui-backend=gtk4` and
`./build.sh bootstrap -ui-backend=gtk3`. Without that option,
`./build.sh bootstrap` uses GTK4 on 64-bit Linux and GTK3 on 32-bit Linux.
You can also set `FACTOR_UI_BACKEND`
to `gtk4` or `gtk3` in the environment. The same option makes UI dependency
commands install the selected GTK version.

On Debian/Ubuntu, `./build.sh deps-apt` installs the compiler, build tools,
OpenSSL development libraries, and the selected GTK dependencies. For a
command-line development environment, use `./build.sh deps-apt-headless`
to install the build tools and OpenSSL without the UI dependencies. Run
`sudo apt-get update` first on a fresh installation.
`./build.sh deps-apt-tests` adds Capstone, Xvfb, and libraries used by the
database, audio, graphics, and other optional vocabulary tests.

Then run the image you want:

```bash
./factor -i=factor-gtk4.image
./factor -i=factor-gtk3.image
```

An ordinary 64-bit Linux bootstrap without `-ui-backend` creates a GTK4
`factor.image`; 32-bit Linux uses GTK3.
Existing GTK3 images keep using GTK3 until rebuilt. The `-ui-backend` option
is a bootstrap option; it does not switch an already-built image. GTK3
requires `libgtk-3-dev` on Debian/Ubuntu, `gtk3-devel` on Fedora, or `gtk3`
on Arch.

To check a GTK4 image on a working display:

```bash
./factor -i=factor-gtk4.image -run=ui.backend.gtk4.smoke-test
```

This opens two windows and checks rendering setup, independent OpenGL
contexts, clipboard and primary-selection text, resizing, and clean shutdown.

GTK4 lets the window manager position windows and manage title-bar buttons.
Captured-input mode focuses the window and hides the pointer, but does not
confine the pointer; applications requiring a native pointer grab can use
the GTK3 image.

### Learning Factor

A [tutorial](https://docs.factorcode.org/content/article-first-program.html)
is available that can be accessed from the Factor environment:

```factor
"first-program" help
```

Take a look at a [guided
tour](https://docs.factorcode.org/content/article-tour.html) of Factor:

```factor
"tour" help
```

Some demos that are included in the distribution to show off various features:

```factor
"demos" run
```

Some other simple things you can try in the listener:

```factor
"Hello, world" print

{ 4 8 15 16 23 42 } [ 2 * ] map .

1000 [1..b] sum .

4 <iota> [
    "Happy Birthday " write
    2 = "dear NAME" "to You" ? print
] each
```

For more tips, see [Learning Factor](https://concatenative.org/wiki/view/Factor/Learning).

## Documentation

The Factor environment includes extensive reference documentation and a
short "cookbook" to help you get started. The best way to read the
documentation is in the UI; press F1 in the UI listener to open the help
browser tool. You can also [browse the documentation
online](https://docs.factorcode.org).

## Command Line Usage

Factor supports a number of command line switches:

```
Usage: factor [Factor arguments] [script] [script arguments]

Common arguments:
    -help            print this message and exit
    -i=<image>       load Factor image file <image> (default factor.image)
    -run=<vocab>     run the MAIN: entry point of <vocab>
        -run=listener    run terminal listener
        -run=ui.tools    run Factor development UI
    -e=<code>        evaluate <code>
    -no-user-init    suppress loading of .factor-rc
    -roots=<paths>   a list of path-delimited extra vocab roots

Enter
    "command-line" help
from within Factor for more information.
```

You can also write scripts that can be run from the terminal, by putting
``#!/path/to/factor`` at the top of your scripts and making them executable.

## Source Organization

The Factor source tree is organized as follows:

* `vm/` - Factor VM source code (not present in binary packages)
* `core/` - Factor core library
* `basis/` - Factor basis library, compiler, tools
* `extra/` - more libraries and applications
* `misc/` - editor modes, icons, etc
* `unmaintained/` - now at [factor-unmaintained](https://github.com/factor/factor-unmaintained)

## Source History

During Factor's lifetime, source code has lived in many repositories. Unfortunately, the first import in Git did not keep history. History has been partially recreated from what could be salvaged. Due to the nature of Git, it's only possible to add history without disturbing upstream work, by using replace objects. These need to be manually fetched, or need to be explicitly added to your git remote configuration.

Use:
`git fetch origin 'refs/replace/*:refs/replace/*'`

or add the following line to your configuration file

```
[remote "origin"]
    url = ...
    fetch = +refs/heads/*:refs/remotes/origin/*
    ...
    fetch = +refs/replace/*:refs/replace/*
```

Then subsequent fetches will automatically update any replace objects.

## Community

Factor developers are quite active in [the Factor Discord server](https://discord.gg/QxJYZx3QDf).
Drop by if you want to discuss anything related to Factor or language design in general.

* [Factor homepage](https://factorcode.org)
* [Concatenative languages wiki](https://concatenative.org)
* [Join the mailing list](https://concatenative.org/wiki/view/Factor/Mailing%20list)
* Search for "factorcode" on [Gitter](https://gitter.im/)

Have fun!
