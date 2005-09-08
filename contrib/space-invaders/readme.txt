This is a first cut at a simple space invaders emulator. The goal is
to produce an emulator, disassembler and assembler for the 8080
processor.

Running 'load.factor' will load the CPU emulation routines and runs
some tests. Run 'gui.factor' to get the SDL based GUI code. 

If you are in the space-invaders directory, and have the ROM as a file
'invaders.rom' in that same directory, the following starts the GUI:

  "load.factor" run-file
  "gui.factor" run-file
  USE: cpu-8080
  display

This will run the emulator in interpreted mode. To compile the Factor
code do the following:

  "cpu-8080" words [ try-compile ] each
  display

This will run much faster.

'Backspace' inserts a coin and '1' is the one player button. It
currently stops working at the point where it displays the invaders
and I'm working on fixing this.

For more information, contact the author, Chris Double, at
chris.double@double.co.nz or from my weblog http://radio.weblogs.com/0102385