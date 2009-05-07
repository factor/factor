! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel multiline ;
IN: literals

HELP: $
{ $syntax "$ word" }
{ $description "Executes " { $snippet "word" } " at parse time and adds the result(s) to the parser accumulator." }
{ $notes { $snippet "word" } "'s definition is looked up and " { $link call } "ed at parse time, so words that reference words in the current compilation unit cannot be used with " { $snippet "$" } "." }
{ $examples

    { $example <"
USING: kernel literals prettyprint ;
IN: scratchpad

CONSTANT: five 5
{ $ five } .
    "> "{ 5 }" }

    { $example <"
USING: kernel literals prettyprint ;
IN: scratchpad

: seven-eleven ( -- a b ) 7 11 ;
{ $ seven-eleven } .
    "> "{ 7 11 }" }

} ;

HELP: $[
{ $syntax "$[ code ]" }
{ $description "Calls " { $snippet "code" } " at parse time and adds the result(s) to the parser accumulator." }
{ $notes "Since " { $snippet "code" } " is " { $link call } "ed at parse time, it cannot reference any words defined in the same compilation unit." }
{ $examples

    { $example <"
USING: kernel literals math prettyprint ;
IN: scratchpad

<< CONSTANT: five 5 >>
{ $[ five dup 1+ dup 2 + ] } .
    "> "{ 5 6 8 }" }

} ;

HELP: ${
{ $syntax "${ code }" }
{ $description "Outputs an array containing the results of executing " { $snippet "code" } " at parse time." }
{ $notes { $snippet "code" } "'s definition is looked up and " { $link call } "ed at parse time, so words that reference words in the current compilation unit cannot be used with " { $snippet "$" } "." }
{ $examples

    { $example <"
USING: kernel literals math prettyprint ;
IN: scratchpad

CONSTANT: five 5
CONSTANT: six 6
${ five six 7 } .
    "> "{ 5 6 7 }"
    }
} ;

{ POSTPONE: $ POSTPONE: $[ POSTPONE: ${ } related-words

ARTICLE: "literals" "Interpolating code results into literal values"
"The " { $vocab-link "literals" } " vocabulary contains words to run code at parse time and insert the results into more complex literal values."
{ $example <"
USING: kernel literals math prettyprint ;
IN: scratchpad

CONSTANT: five 5
{ $ five $[ five dup 1+ dup 2 + ] } .
    "> "{ 5 5 6 8 }" }
{ $subsection POSTPONE: $ }
{ $subsection POSTPONE: $[ }
{ $subsection POSTPONE: ${ }
;

ABOUT: "literals"
