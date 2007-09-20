The Factor programming language
-------------------------------

This file covers installation and basic usage of the Factor
implementation. It is not an introduction to the language itself.

* Contents

- Platform support
- Compiling the Factor VM
- Bootstrapping the Factor image
- Running Factor on Unix with X11
- Running Factor on Mac OS X - Cocoa UI
- Running Factor on Mac OS X - X11 UI
- Running Factor on Windows
- Command line usage
- Source organization
- Community

* Platform support

Factor supports the following platforms:

  Linux/x86
  Linux/AMD64
  Linux/PowerPC
  Linux/ARM
  Mac OS X/x86
  Mac OS X/PowerPC
  FreeBSD/x86
  FreeBSD/AMD64
  OpenBSD/x86
  OpenBSD/AMD64
  Solaris/x86
  Solaris/AMD64
  MS Windows/x86 (XP and above)
  MS Windows CE/ARM

Please donate time or hardware if you wish to see Factor running on
other platforms. In particular, we are interested in:

  Windows/AMD64
  Mac OS X/AMD64
  Solaris/UltraSPARC
  Linux/MIPS

* Compiling the Factor VM

The Factor runtime is written in GNU C99, and is built with GNU make and
gcc.

Factor requires gcc 3.4 or later. On x86, it /will not/ build using gcc
3.3 or earlier.

Run 'make' (or 'gmake' on *BSD) with no parameters to see a list of
targets and build options. Then run 'make' with the appropriate target
for your platform.

Compilation will yield an executable named 'factor' on Unix,
'factor-nt.exe' on Windows XP/Vista, and 'factor-ce.exe' on Windows CE.

* Bootstrapping the Factor image

The boot images are no longer included with the Factor distribution
due to size concerns. Instead, download a boot image from:

  http://factorcode.org/images/

Once you have compiled the Factor runtime, you must bootstrap the Factor
system using the image that corresponds to your CPU architecture.

Once you download the right image, bootstrap the system with the
following command line:

./factor -i=boot.<cpu>.image

Bootstrap can take a while, depending on your system. When the process
completes, a 'factor.image' file will be generated. Note that this image
is both CPU and OS-specific, so in general cannot be shared between
machines.

* Running Factor on Unix with X11

On Unix, Factor can either run a graphical user interface using X11, or
a terminal listener.

If your DISPLAY environment variable is set, the UI will start
automatically:

  ./factor

To run an interactive terminal listener:

  ./factor -run=listener

If you're inside a terminal session, you can start the UI with one of
the following two commands:

  ui
  [ ui ] in-thread
  
The latter keeps the terminal listener running.

* Running Factor on Mac OS X - Cocoa UI

On Mac OS X 10.4 and later, a Cocoa UI is available in addition to the
terminal listener. If you are using Mac OS X 10.3, you can only run the
X11 UI, as documented in the next section.

The 'factor' executable runs the terminal listener:

  ./factor

The 'Factor.app' bundle runs the Cocoa UI. Note that this is not a
self-contained bundle, it must be run from the same directory which
contains factor.image and the library sources.

* Running Factor on Mac OS X - X11 UI

The X11 UI is available on Mac OS X, however its use is not recommended
since it does not integrate with the host OS. However, if you are
running Mac OS X 10.3, it is your only choice.

When compiling Factor, pass the X11=1 parameter:

  make macosx-ppc X11=1

Then bootstrap with the following switches:

  ./factor -i=boot.ppc.image -ui-backend=x11

Now if $DISPLAY is set, running ./factor will start the UI.

* Running Factor on Windows XP/Vista

If you did not download the binary package, you can bootstrap Factor in
the command prompt:

  factor-nt.exe -i=boot.x86.32.image

Once bootstrapped, double-clicking factor.exe starts the Factor UI.

To run the listener in the command prompt:

  factor-nt.exe -run=listener

* Command line usage

The Factor VM supports a number of command line switches. To read
command line usage documentation, either enter the following in the UI
listener:

  "command-line" about

* Source organization

The following two directories are managed by the module system; consult
the documentation for details:

  core/ - Factor core library and compiler
  extra/ - more libraries

The following directories contain additional files:

  misc/ - editor modes, icons, etc
  vm/ - sources for the Factor runtime, written in C
  fonts/ - TrueType fonts used by UI
  unmaintained/ - unmaintained contributions, please help!

* Community

The Factor homepage is located at <http://factorcode.org/>.

Factor developers meet in the #concatenative channel on the
irc.freenode.net server. Drop by if you want to discuss anything related
to Factor or language design in general.

Have fun!

:tabSize=2:indentSize=2:noTabs=true:
