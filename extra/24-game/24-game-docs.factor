USING: arrays help.markup help.syntax kernel math ;
IN: 24-game

HELP: 24-game
{ $description "Starts the game!" }
{ $examples
    { $unchecked-example
        "USE: 24-game"
        "24-game"
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

HELP: make-24
{ $values { "array" array } }
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
        "make-24 length 4 = ."
        "t"
    }
    { $notes { $link makes-24? } " is used in " { $link makes-24? } "." }
} ;

HELP: makes-24?
{ $values
    { "a" integer }
    { "b" integer }
    { "c" integer }
    { "d" integer }
    { "?" boolean }
}
{ $description
    "Tells if it is possible to win 24-game with these integers."
} ;

ARTICLE: "24-game" "The Game of 24"
"A classic math game, where one attempts to create 24, by applying "
"arithmetical operations and some shuffle words to a stack of 4 numbers."
{ $subsections
    24-game
    make-24
    makes-24?
} ;
ABOUT: "24-game"
