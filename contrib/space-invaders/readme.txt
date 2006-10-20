This is a simple space invaders emulator. The goal is to produce an
emulator, disassembler and assembler for the 8080 processor.

It is integrated into the Factor module system, the following will
load all necessary files and run it:

  "contrib/space-invaders" require
  "contrib/space-invaders" run-module

For this to work it needs a ROM file called 'invaders.rom' in the
factor root directory.

'Backspace' inserts a coin, '1' is the one player button and '2' is
the two play button. The left and right arrow keys move and the up
arrow key fires.

If the ROM file you have is split into seperate files, you will need
to merge them into one 'invaders.rom' file. From Windows this is done
with:

  copy /b invaders.h+invaders.g+invaders.f+invaders.e invaders.rom

Or Linux:

  cat invaders.h invaders.g invaders.f invaders.e >invaders.rom

The emulator is actually a generic Intel 8080 and the code for this is
in cpu-8080.factor. The space invaders specific code is in
space-invaders.factor. It specializes generic functions defined by the
8080 emulator code to handle the space invaders display and
input/output ports.

Current Issues:

1) The Escape key does not close the GUI. It does stop the CPU
   emulation process though.

2) The best way of stopping if to just close the GUI window.

For more information, contact the author, Chris Double, at
chris.double@double.co.nz or from my weblog
http://www.bluishcoder.co.nz
