This is a simple space invaders emulator. The goal is to produce an
emulator, disassembler and assembler for the 8080 processor.

Running 'load.factor' will load all necessary files to run the game.

If you are in the factor root directory, and have the ROM as a file
'invaders.rom' in that same directory, the following starts the GUI:

  "contrib/space-invaders/load.factor" run-file
  USE: space-invaders
  run 

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

1) The Factor GUI doesn't seperate key events into 'up' and 'down'
events. Space Invaders requires this so we fake the up event. This
causes a delay when pressing keys which makes the game hard to play.

2) The Escape key does not close the GUI. It does stop the CPU
emulation process though.

3) Closing the GUI using the 'X' does not stop the CPU emulation
process. This needs to be stopped by sending "stop" to the process
returned from 'run':
  USE: concurency
  "stop" swap send

4) The best way of closing the window is by pressing Escape and then
   'X' on the window.

For more information, contact the author, Chris Double, at
chris.double@double.co.nz or from my weblog
http://www.bluishcoder.co.nz
