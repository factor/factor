! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup cpu.8080.emulator ;
IN: roms.space-invaders

HELP: run-invaders
{ $description
"Run the Space Invaders emulator in a new window." $nl
{ $link rom-root } " must be set to the directory containing the "
"location of the Space Invaders ROM files. See "
{ $link "space-invaders" } " for details."
} ;

ARTICLE: "space-invaders" "Space Invaders Emulator"
"Provides an emulation of the original 8080 Arcade Game 'Space Invaders'." $nl
"More information on the arcade game can be obtained from " { $url "https://www.emuparadise.me/M.A.M.E._-_Multiple_Arcade_Machine_Emulator_ROMs/Space_Invaders_--_Space_Invaders_M/13774" } "." $nl
"To play the game you need the ROM files for the arcade game. They should "
"be placed in a directory called 'invaders' in the location specified by "
"the variable " { $link rom-root } ". The specific files needed are:"
{ $list
  "invaders/invaders.e"
  "invaders/invaders.f"
  "invaders/invaders.g"
  "invaders/invaders.h"
}
"These are the same ROM files as used by MAME. To run the game use the "
{ $link run-invaders } " word." $nl
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

ABOUT: "space-invaders"
