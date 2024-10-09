! Copyright (C) 2024 Dmitry Matveyev.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel raylib multiline ;
FROM: vocabs.refresh => refresh-all ;
IN: raylib.live-coding

HELP: lc-sleep-duration
{ $var-description "Amount of time slept every frame in the game window, giving control back to the Listener." } ;

HELP: on-key-reload-code
{ $values
    { "key" { $link KeyboardKey } }
}
{ $description "Binds a key to reload the game from within a game. This is the same as calling "
    { $link refresh-all } " from the Listener." } ;

HELP: until-window-should-close-with-live-coding
{ $values
    { "game-loop-quot" "main game loop that must recurse until the game is closed" }
}
{ $description "Combines both an unending iteration of the supplised game loop quotation as well as inserts pauses for " { $link lc-sleep-duration } " giving control to the Listener." } ;

HELP: with-live-coding
{ $values
    { "main-quot" "main entry point into the program" }
}
{ $description "Sets up environment and runs the game in another thread. Can be convenient to define a word that does this for you." }
{ $examples
    { $example [[ USING: raylib.live-coding ;

: dev ( -- )
    [ main ] with-live-coding ; ]]
    ""
    }
} ;

ARTICLE: "raylib.live-coding" "Raylib Live Coding"
{ $vocab-link "raylib.live-coding" } $nl
"With this library you can change the game while it is running. You can:" {
$list
"Add new code and reload the game"
"Inspect and change the environment right from the Listener"
"Choose whether to close the game or continue if there's an error during execution"
} $nl

"See the demo "
{ $vocab-link "raylib.demo.live-coding" } " for a usual set up. In the demo try to do the following: " {
$list
{ "Enter demo's vocabulary with " { $snippet "IN: raylib.demo.live-coding" } ", load all code with F2 and finally run " { $snippet "dev" } " to launch a game." }
[[ Wait until the counter reaches 100 and you get a restartable error. Don't choose "Abort", since it will fail to clear up the state. ]]
{ "Run " { $snippet "0 counter set" } " in the Listener and see that the counter is reset to 0. You will get another restartable error when it reaches 100." }
{ "In the code, comment the line with " { $snippet "draw-text" } ", then come back to Listener and press F2 to refresh all vocabularies. See that the counter disappeared." }
"Uncomment this line again, click on the game window to focus it and press F5. The counter will appear again."
{ "Run " { $snippet "text-color get" } " to put on the stack the object that defines counter's color. "
  "Click on the " { $snippet "~Color~" } " with a mouse, right on the value on the stack. "
  "Then choose any slot, for example, " { $snippet "r" } ", at the top click on Edit Slot and type some value between 0 and 255, choose Commit. "
  "See that the counter color has changed." }
}
;

ABOUT: "raylib.live-coding"
