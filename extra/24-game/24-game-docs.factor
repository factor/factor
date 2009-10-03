USING: help.markup help.syntax math kernel ;
IN: 24-game

HELP: play-game ( -- )
{ $description "Starts the game!" }
{ $examples
    { $unchecked-example
        "USE: 24-game"
        "play-game"
        "{ 8 2 1 2 }\n"
        "Commands: { + - * / rot swap q }\n"
        "swap\n"
        "{ 8 2 2 1 }\n"
        "Commands: { + - * / rot swap q }\n"
        "-\n"
        "{ 8 2 1 }\n"
        "Commands: { + - * / rot swap q }\n"
        "+\n"
        "{ 8 3 }\n"
        "Commands: { + - * / swap q }\n"
        "*\n"
        "You WON!"
    }
} ;

HELP: 24-able ( -- vector )
{ $values { "vector" "vector of 4 integers" } }
{ $description
    "Produces a vector with 4 integers. With the following condition: "
    "If these integers were directly on the stack, one can process them into 24, "
    "just using the provided commands and the 4 numbers. The Following are the "
    "provided commands: "
    { $link + } ", " { $link - } ", " { $link * } ", "
    { $link / } ", " { $link swap } ", and " { $link rot } "."
}
{ $examples
    { $example
        "USING: 24-game kernel sequences prettyprint ;"
        "24-able length 4 = ."
        "t"
    }
    { $notes { $link 24-able? } " is used in " { $link 24-able } "." }
} ;

HELP: 24-able? ( quad -- t/f )
{ $values
    { "quad" "vector of 4 integers" }
    { "t/f" "a boolean" }
}
{ $description
    "Tells if it is possible to win 24-game if it was initiated "
    "with this sequence."
} ;

HELP: build-quad ( -- array )
{ $values
    { "array" "an array of 4 numbers" }
}
{ $description "Builds an array of 4 random numbers." } ;
ARTICLE: "24-game" "The Game of 24"
"A classic math game, where one attempts to create 24, by applying "
"arithmetical operations and some shuffle words to a stack of 4 numbers. "
{ $subsections
    play-game
    24-able
    24-able?
    build-quad
} ;
ABOUT: "24-game"
