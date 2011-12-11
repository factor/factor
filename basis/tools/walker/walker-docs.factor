IN: tools.walker
USING: help.syntax help.markup tools.continuations sequences math words ;

HELP: breakpoint
{ $values { "word" word } }
{ $description "Annotates a word definition to enter the single stepper when executed." } ;

HELP: breakpoint-if
{ $values { "word" word } { "quot" { $quotation "( -- ? )" } } }
{ $description "Annotates a word definition to enter the single stepper if the quotation yields true." } ;

HELP: B
{ $description "An alias for " { $link break } ", defined in the " { $vocab-link "syntax" } " vocabulary so that it is always available." } ;

HELP: B:
{ $description "A breakpoint for parsing words. When this word is executed, it copies the definition of the following parsing word, prepends a " { $link break } " to it so that it is the first word to be executed when the definition is called, and calls this new definition.\n\nWhen the walker tool opens, execution will still be inside " { $link POSTPONE: B: } ". To step out of B: and into the parsing word, do just that: jump out with O, then into with I." } ;

ARTICLE: "breakpoints" "Setting breakpoints"
"In addition to invoking the walker explicitly through the UI, it is possible to set breakpoints on words using words in the " { $vocab-link "tools.walker" } " vocabulary."
$nl
"Annotating a word with a breakpoint (see " { $link "tools.annotations" } "):"
{ $subsections
    breakpoint
    breakpoint-if
}
"Breakpoints can be inserted directly into code:"
{ $subsections
    break
    POSTPONE: B
    POSTPONE: B:
}
"Note that because the walker calls various core library and UI words while rendering its own user interface, setting a breakpoint on a word such as " { $link append } " or " { $link + } " will hang the UI." ;

ABOUT: "breakpoints"
