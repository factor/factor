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

Factor does not yet work on arm64 cpus. There is an arm64 assembler
in `cpu.arm.64.assembler` and we are working on a port and also looking for
contributors.

More information on [building factor](https://concatenative.org/wiki/view/Factor/Building%20Factor)
and [system requirements](https://concatenative.org/wiki/view/Factor/Requirements).

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
`./build.sh bootstrap` uses GTK4. You can also set `FACTOR_UI_BACKEND`
to `gtk4` or `gtk3` in the environment. The same option makes `deps-*` commands
install the selected GTK version.

Then run the image you want:

```bash
./factor -i=factor-gtk4.image
./factor -i=factor-gtk3.image
```

An ordinary bootstrap without `-ui-backend` creates a GTK4 `factor.image`.
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
