The Factor programming language
-------------------------------

This file covers installation and basic usage of the Factor
implementation. It is not an introduction to the language itself.

* Contents

- Compiling the Factor VM
- Libraries needed for compilation
- Bootstrapping the Factor image
- Running Factor on Unix with X11
- Running Factor on Mac OS X - Cocoa UI
- Running Factor on Mac OS X - X11 UI
- Running Factor on Windows
- Command line usage
- The Factor FAQ
- Source organization
- Community

* Compiling the Factor VM

Factor supports various platforms. For an up-to-date list, see
<http://factorcode.org>.

The Factor VM is written in C++ and uses GNU extensions. When compiling
with GCC 3.x, boost::unordered_map must be installed. On GCC 4.x, Factor
uses std::tr1::unordered_map which is shipped as part of GCC.

Run 'make' ('gmake' on *BSD) with no parameters to build the Factor VM.

* Bootstrapping the Factor image

Once you have compiled the Factor VM, you must bootstrap the Factor
system using the image that corresponds to your CPU architecture.

Boot images can be obtained from <http://factorcode.org/images/latest/>.

Once you download the right image, bootstrap Factor with the
following command line:

./factor -i=boot.<cpu>.image

Bootstrap can take a while, depending on your system. When the process
completes, a 'factor.image' file will be generated. Note that this image
is both CPU and OS-specific, so in general cannot be shared between
machines.

* Running Factor on Unix with X11

On Unix, Factor can either run a graphical user interface using X11, or
a terminal listener.

For X11 support, you need recent development libraries for libc,
Pango, X11, and OpenGL. On a Debian-derived Linux distribution
(like Ubuntu), you can use the following line to grab everything:

    sudo apt-get install libc6-dev libpango-1.0-dev libx11-dev

If your DISPLAY environment variable is set, the UI will start
automatically:

  ./factor

To run an interactive terminal listener:

  ./factor -run=listener

* Running Factor on Mac OS X - Cocoa UI

On Mac OS X, a Cocoa UI is available in addition to the terminal
listener.

The 'factor' executable runs the terminal listener:

  ./factor

The 'Factor.app' bundle runs the Cocoa UI. Note that this is not a
self-contained bundle, it must be run from the same directory which
contains factor.image and the library sources.

* Running Factor on Mac OS X - X11 UI

The X11 UI is also available on Mac OS X, however its use is not
recommended since it does not integrate with the host OS.

When compiling Factor, pass the X11=1 parameter:

  make X11=1

Then bootstrap with the following switches:

  ./factor -i=boot.<cpu>.image -ui-backend=x11

Now if $DISPLAY is set, running ./factor will start the UI.

* Running Factor on Windows XP/Vista

The Factor runtime is compiled into two binaries:

  factor.com - a Windows console application
  factor.exe - a Windows native application, without a console

If you did not download the binary package, you can bootstrap Factor in
the command prompt using the console application:

  factor.com -i=boot.<cpu>.image

Once bootstrapped, double-clicking factor.exe or factor.com starts
the Factor UI.

To run the listener in the command prompt:

  factor.com -run=listener

* The Factor FAQ

The Factor FAQ is available at the following location:

  <http://concatenative.org/wiki/view/Factor/FAQ>

* Command line usage

Factor supports a number of command line switches. To read command line
usage documentation, enter the following in the UI listener:

  "command-line" about

* Source organization

The Factor source tree is organized as follows:

  build-support/ - scripts used for compiling Factor
  vm/ - Factor VM
  core/ - Factor core library
  basis/ - Factor basis library, compiler, tools
  extra/ - more libraries and applications
  misc/ - editor modes, icons, etc
  unmaintained/ - unmaintained contributions, please help!

* Community

The Factor homepage is located at <http://factorcode.org/>.

Factor developers meet in the #concatenative channel on the
irc.freenode.net server. Drop by if you want to discuss anything related
to Factor or language design in general.

Have fun!

:tabSize=2:indentSize=2:noTabs=true:
