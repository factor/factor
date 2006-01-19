This is a first cut at a simple space invaders emulator. The goal is
to produce an emulator, disassembler and assembler for the 8080
processor.

Running 'load.factor' will load all necessary files to run the game.

If you are in the space-invaders directory, and have the ROM as a file
'invaders.rom' in that same directory, the following starts the GUI:

  "load.factor" run-file
  USE: space-invaders
  run

'Backspace' inserts a coin, '1' is the one player button and '2' is
the two play button. The left and right arrow keys move and the left
control key fires.

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

For more information, contact the author, Chris Double, at
chris.double@double.co.nz or from my weblog
http://www.bluishcoder.co.nz
