The Factor programming language
-------------------------------

This file covers installation and basic usage of the Factor
implementation. It is not an introduction to the language itself.

* Contents

- Platform support
- Compiling Factor
- Building Factor
- Running Factor on Unix with X11
- Running Factor on Mac OS X
- Running Factor on Windows
- Source organization
- Community
- Credits

* Platform support

Factor is fully supported on the following platforms:

  Linux/x86
  Linux/AMD64
  Mac OS X/PowerPC

The following platforms should work, but are not tested on a
regular basis:

  FreeBSD/x86
  FreeBSD/AMD64
  Solaris/x86
  Solaris/AMD64
  Linux/PowerPC
  Microsoft Windows 2000 or later

Please donate time or hardware if you wish to see Factor running on
other platforms.

* Compiling Factor

The Factor runtime is written in C, and is built with GNU make and gcc.

Factor requires gcc 3.4 or later. On x86, it /will not/ build using gcc
3.3 or earlier.

Run 'make' (or 'gmake' on non-Linux platforms) with one of the following
parameters to build the Factor runtime:

  bsd
  linux
  linux-ppc
  macosx
  solaris
  windows

The following options can be given to make:

  SITE_CFLAGS="..."
  DEBUG=1

The former allows optimization flags to be specified, for example
"-march=pentium4 -ffast-math -O3". Nowadays most of the hard work is
done by Factor compiled code, so optimizing the runtime is not that
important. Usually the defaults are fine.

The DEBUG flag disables optimization and builds an executable with
debug symbols. This is probably only of interest to people intending to
hack on the runtime sources.

Compilation may print a handful of warnings about singled/unsigned
comparisons, and violated aliasing contracts. They may safely be
ignored.

Compilation will yield an executable named 'f'.

* Building Factor

The Factor source distribution ships with four boot image files:

  boot.image.x86
  boot.image.pentium4 -- uses SSE2, only for Pentium 4 and later
  boot.image.ppc
  boot.image.amd64

Once you have compiled the Factor runtime, you must bootstrap the Factor
system using the image that corresponds to your CPU architecture.

The system is bootstrapped with the following command line:

./f boot.image.<foo>

Bootstrap can take a while, depending on your system. When the process
completes, a 'factor.image' file will be generated. Note that this image
is both CPU and OS-specific, so in general cannot be shared between
machines.

* Running Factor on Unix with X11

On Unix, Factor can either run a graphical user interface using X11, or
a terminal listener.

If your DISPLAY environment variable is set, the UI will start
automatically:

  ./f factor.image

To run an interactive terminal listener:

  ./f factor.image -shell=tty

If you're inside a terminal session, you can start the UI with one of
the following two commands:

  ui
  [ ui ] in-thread
  
The latter keeps the terminal listener running.

* Running Factor on Mac OS X

On Mac OS X, a Cocoa UI is available in addition to the terminal
listener.

The 'f' executable runs the terminal listener:

  ./f factor.image

The Cocoa UI requires that after bootstrapping you build the Factor.app
application bundle:

  make macosx.app

This copies the runtime executable, factor.image (which must exist at
this point), and the library source into a self-contained Factor.app.

Factor.app runs the UI when double-clicked and can be transported
between PowerPC Macs.

* Running Factor on Windows

On Windows, double-clicking f.exe will start running the Win32-based UI
with the factor.image in the same directory as the executable.

Bootstrap runs in a Windows command prompt, however there is no
terminal listener and after bootstrapping only the UI can be used.

* Source organization

  doc/ - the developer's handbook, and various other bits and pieces
  native/ - sources for the Factor runtime, written in C
  library/ - sources for the library, written in Factor
  contrib/ - various handy libraries not part of the core
  examples/ - small examples illustrating various language features
  fonts/ - TrueType fonts used by UI

* Community

The Factor homepage is located at http://factorcode.org/.

Factor developers meet in the #concatenative channel on the
irc.freenode.net server. Drop by if you want to discuss anything related
to Factor or language design in general.

* Credits

The following people have contributed code to the Factor core:

Slava Pestov:       Lead developer
Alex Chapman:       OpenGL binding
Doug Coleman:       Mersenne Twister RNG, Windows port
Eduardo Cavazos:    X11 binding
Mackenzie Straight: Windows port
Trent Buck:         Debian package

A number of contributed libraries not part of the core can be found in
contrib/. See contrib/README.txt for details.

Have fun!

:tabSize=2:indentSize=2:noTabs=true:
