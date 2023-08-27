! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup cpu.8080.emulator ;
IN: roms.lunar-rescue

HELP: run-lunar
{ $description
"Run the Lunar Rescue emulator in a new window." $nl
{ $link rom-root } " must be set to the directory containing the "
"location of the Lunar Rescue ROM files. See "
{ $link "lunar-rescue" } " for details."
} ;

ARTICLE: "lunar-rescue" "Lunar Rescue Emulator"
"Provides an emulation of the original 8080 Arcade Game 'Lunar Rescue'." $nl
"More information on the arcade game can be obtained from " { $url "https://www.emuparadise.me/M.A.M.E._-_Multiple_Arcade_Machine_Emulator_ROMs/Lunar_Rescue/14294" } "." $nl
"To play the game you need the ROM files for the arcade game. They should "
"be placed in a directory called " { $snippet "lrescue" } " in the location specified by "
"the variable " { $link rom-root } ". The specific files needed are:"
{ $list
  "lrescue/lrescue.1"
  "lrescue/lrescue.2"
  "lrescue/lrescue.3"
  "lrescue/lrescue.4"
  "lrescue/lrescue.5"
  "lrescue/lrescue.6"
}
"These are the same ROM files as used by MAME. To run the game use the "
{ $link run-lunar } " word." $nl
"Keys:"
{ $table
  { "Backspace" "Insert Coin" }
  { "1" "1 Player" }
  { "2" "2 Player" }
  { "Left" "Move Left" }
  { "Right" "Move Right" }
  { "Up" "Fire or apply thrusters" }
}
"If you save the Factor image while a game is running, when you restart "
"the image the game continues where it left off." ;

ABOUT: "lunar-rescue"
