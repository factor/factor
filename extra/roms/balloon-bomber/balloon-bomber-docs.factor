! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup cpu.8080.emulator ;
IN: roms.balloon-bomber

HELP: run-balloon
{ $description
"Run the Balloon Bomber emulator in a new window." $nl
{ $link rom-root } " must be set to the directory containing the "
"location of the Balloon Bomber ROM files. See "
{ $link "balloon-bomber" } " for details."
} ;

ARTICLE: "balloon-bomber" "Balloon Bomber Emulator"
"Provides an emulation of the original 8080 Arcade Game 'Balloon Bomber'." $nl
"More information on the arcade game can be obtained from " { $url "https://www.emuparadise.me/M.A.M.E._-_Multiple_Arcade_Machine_Emulator_ROMs/Balloon_Bomber/11301" } "." $nl
"To play the game you need the ROM files for the arcade game. They should "
"be placed in a directory called 'ballbomb' in the location specified by "
"the variable " { $link rom-root } ". The specific files needed are:"
{ $list
  "ballbomb/tn01"
  "ballbomb/tn02"
  "ballbomb/tn03"
  "ballbomb/tn04"
  "ballbomb/tn05-1"
}
"These are the same ROM files as used by MAME. To run the game use the "
{ $link run-balloon } " word." $nl
"Keys:"
{ $table
  { "Backspace" "Insert Coin" }
  { "1" "1 Player" }
  { "2" "2 Player" }
  { "Left" "Move Left" }
  { "Right" "Move Right" }
  { "Up" "Fire" }
}
"If you save the Factor image while a game is running, when you restart "
"the image the game continues where it left off." ;

ABOUT: "balloon-bomber"
