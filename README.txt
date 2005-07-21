The Factor programming language
-------------------------------

This file covers installation and basic usage of the Factor
implementation. It is not an introduction to the language itself.

* Platform support

Factor is fully supported on the following platforms:

  Linux/x86
  FreeBSD/x86
  Microsoft Windows 2000 or later
  Mac OS X/PowerPC
  Linux/PowerPC

While Factor may run on other platforms (Solaris/Sparc, Linux/Alpha, and
so on), the native compiler will not be available, and thus much
functionality will be missing. In particular, the following features
require the native compiler and only work on supported platforms:

  C library interface
  Non-blocking I/O
  Networking

* Compiling Factor

The Factor runtime is written in C, and is built with GNU make and gcc.

Note that on x86 systems, Factor _cannot_ be compiled with gcc 3.3. This
is due to a bug in gcc and there is nothing we can do about it. Please
use gcc 2.95, 3.4, or 4.0.

Run 'make' (or 'gmake' on non-Linux platforms) with one of the following
parameters to build the Factor runtime:

  bsd
  linux
  linux-ppc
  macosx
  windows

The following options can be given to make:

  SITE_CFLAGS="..."
  DEBUG=1

The former allows optimization flags to be specified, for example
"-march=pentium4 -ffast-math -O3". Optimization flags can make a *huge*
difference in Factor's performance, so willing hackers should
experiment.

The latter flag disables optimization and builds an executable with
debug symbols. This is probably only of interest to people intending to
hack on the runtime sources.

Compilation may print a handful of warnings about singled/unsigned
comparisons, and violated aliasing contracts. They may safely be
ignored.

Compilation will yield an executable named 'f'.

* Building Factor

The Factor source distribution ships with four boot image files:

  boot.image.le32 - for x86
  boot.image.be32 - for PowerPC, SPARC
  boot.image.le64 - for x86-64
  boot.image.be64 - for Alpha, PowerPC/64, UltraSparc

Once you have compiled the Factor runtime, you must bootstrap the Factor
system using the image that corresponds to your CPU architecture.

The system is bootstrapped with the following command line:

./f boot.image.<foo>

Additional options may be specified to load external C libraries; see
the next section for details.

Bootstrap can take a while, depending on your system. When the process
completes, a 'factor.image' file will be generated. Note that this image
is both CPU and OS-specific, so in general cannot be shared between
machines.

* Running Factor

To run the Factor system, issue the following command:

  ./f factor.image

This will start the interactive listener where Factor expressions may
be entered.

To run the graphical user interface, issue the following command:

  ./f factor.image -shell=ui

Note that on Windows, this is the default.

On Unix, this might fail if the SDL libraries are not installed, or are
installed under unconventional names. This can be solved by explicitly
naming the libraries during bootstrap, as in the next section.

* Setting up SDL libraries for use with Factor

Factor's UI requires recent versions of the following three libraries in
order to operate:

  libSDL.so
  libSDL_ttf.so
  libSDL_gfx.so

If you have installed these libraries but the UI still fails with an
error, you will need to find out the exact names that they are installed
as, and issue a command similar to the following to bootstrap Factor:

  ./f boot.image.<foo> -libraries:sdl:name=libSDL-1.2.so
                       -libraries:sdl-ttf:name=libSDL_ttf.so
                       -libraries:sdl-gfx:name=libSDL_gfx.so

* Source organization

  doc/ - the developer's handbook, and various other bits and pieces
  native/ - sources for the Factor runtime, written in C
  library/ - sources for the library, written in Factor
    alien/ - C library interface
    bootstrap/ - code for generating boot images
    collections/ - data types including but not limited to lists,
      vectors, hashtables, and operations on them
    compiler/ - optimizing native compiler
    generic/ - generic words, for object oriented programming style
    help/ - online help system
    httpd/ - HTTP client, server, and web application framework
    icons/ - images used by web framework and UI
    inference/ - stack effect inference, used by compiler, as well as a
      useful development tool of its own
    io/ - input and output streams
    math/ - integers, ratios, floats, complex numbers, vectors, matrices
    sdl/ - bindings for libSDL, libSDL_ttf and libSDL_gfx
    syntax/ - parser and object prettyprinter
    test/ - unit test framework and test suite
    tools/ - interactive development tools
    ui/ - UI framework
    unix/ - Unix-specific I/O code
    win32/ - Windows-specific I/O code
  contrib/ - various handy libraries not part of the core
  examples/ - small examples illustrating various language features
  factor/ - Java code for the Factor jEdit plugin
  fonts/ - TrueType fonts used by UI

* Learning Factor

The UI has a simple tutorial that will show you the most basic concepts.

There is a detailed language and library reference available at
http://factor.sourceforge.net/handbook.pdf.

You can browse the source code; it is organized into small,
well-commented files and should be easy to follow once you have a good
grasp of the language.

* Community

The Factor homepage is located at http://factor.sourceforge.net/.

Factor developers meet in the #concatenative channel on the
irc.freenode.net server. Drop by if you want to discuss anything related
to Factor or language design in general.

Have fun!

:tabSize=2:indentSize=2:noTabs=true:
