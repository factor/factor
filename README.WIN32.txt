FACTOR ON WINDOWS

The Windows port of Factor requires Windows 2000 or later. If you are
using Windows 95, 98 or NT, you might be able to get the Unix port of
Factor running inside Cygwin. Or you might not.

A precompiled factor.exe is included with the download, along with
SDL.dll and SDL_gfx.dll. The SDL libraries are required for the
interactive interpreter. Factor does not use the Windows console,
because it does not support asynchronous I/O.

To run the Windows port, open a DOS prompt and type:

  cd <directory where Factor is installed>

  factor.exe boot.image.le32
... Files are loaded and factor.image is written.

  factor.exe factor.image
... Factor starts the SDL console now.
