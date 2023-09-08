IN: tools.walker
USING: help.syntax help.markup tools.annotations tools.continuations sequences math words ;

HELP: breakpoint
{ $values { "word" word } }
{ $description "Annotates a word definition to enter the single stepper when executed. Use " { $link reset } " to clear." }
{ $examples
    { $unchecked-example "USE: tools.walker \\ sq breakpoint"
        ""
    }
} ;

HELP: breakpoint-if
{ $values { "word" word } { "quot" { $quotation ( ... -- ... ? ) } } }
{ $description "Annotates a word definition to enter the single stepper if the quotation yields true. The quotation has access to the datastack as it exists just before " { $snippet "word" } " is called. Use " { $link reset } " to clear." }
{ $examples
    "Break if the input to sq is 3:"
    { $code
        "USE: tools.walker \\ sq [ dup 3 = ] breakpoint-if"
    }
} ;

HELP: breakpoint-after
{ $values { "word" word } { "n" number } }
{ $description "Annotates a word definition to enter the single stepper after the word has been called " { $snippet "n" } " times. Use " { $link reset } " to clear." }
{ $examples
    "Break after calling sq 3 times:"
    { $code
        "USE: tools.walker \\ sq 3 breakpoint-after"
    }
} ;

HELP: B
{ $description "An alias for " { $link break } ", defined in the " { $vocab-link "syntax" } " vocabulary so that it is always available." } ;

HELP: B:
{ $description "A breakpoint for parsing words. When this word is executed, it copies the definition of the following parsing word, prepends a " { $link break } " to it so that it is the first word to be executed when the definition is called, and calls this new definition.\n\nWhen the walker tool opens, execution will still be inside " { $link POSTPONE: B: } ". To step out of B: and into the parsing word, do just that: jump out with O, then into with I." } ;

HELP: step-into
{ $var-description "Signal set to the walker thread to step into the word." } ;

ARTICLE: "breakpoints" "Setting breakpoints"
"In addition to invoking the walker explicitly through the UI, it is possible to set breakpoints on words using words in the " { $vocab-link "tools.walker" } " vocabulary."
$nl
"Annotating a word with a breakpoint (see " { $link "tools.annotations" } "):"
{ $subsections
    breakpoint
    breakpoint-if
    breakpoint-after
}
"Breakpoints can be inserted directly into code:"
{ $subsections
    break
    POSTPONE: B
    POSTPONE: B:
}
"Note that because the walker calls various core library and UI words while rendering its own user interface, setting a breakpoint on a word such as " { $link append } " or " { $link + } " will hang the UI." ;

ABOUT: "breakpoints"
