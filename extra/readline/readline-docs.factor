! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: readline

HELP: readline
{ $values
    { "prompt" string }
    { "str" string }
}
{ $description "Read a line from using readline." } ;

HELP: set-completion
{ $values
    { "quot" { $quotation ( str n -- str ) } }
}
{ $description "Set the given quotation as the completion hook for readline. The quotation is called with the string to complete and the index in the completion list to return. When all completions have been returned, returning " { $snippet "f" } " terminates the loop." }
{ $examples
    { $unchecked-example "USING: readline sequences combinators kernel ;"
               "[ nip [ \"keep\" \"dip\" ] ?nth ] set-completion"
               ""
    }
} ;

ARTICLE: "readline" "Readline"
"The " { $vocab-link "readline" } " vocabulary binds to the C readline library and provides Emacs-style key bindings for editing text. Currently, it only works from the non-graphical UI." $nl

"To read a line:"
{ $subsections readline }
"To set a completion hook:"
{ $subsections set-completion } ;

ABOUT: "readline"
