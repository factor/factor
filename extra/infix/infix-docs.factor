! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math math.functions ;
IN: infix

HELP: [infix
{ $syntax "[infix ... infix]" }
{ $description "Parses the infix code inside the brackets, converts it to stack code and executes it." }
{ $examples
    { $example
        "USING: infix prettyprint ;"
        "IN: scratchpad"
        "[infix 8+2*3 infix] ."
        "14"
    } $nl
    { $link POSTPONE: [infix } " isn't that useful by itself, as it can only access literal numbers and no variables. It is designed to be used together with locals; for example with " { $link POSTPONE: :: } " :"
    { $example
        "USING: infix locals math.functions prettyprint ;"
        "IN: scratchpad"
        ":: quadratic-equation ( a b c -- z- z+ )"
        "    [infix (-b-sqrt(b*b-4*a*c)) / (2*a) infix]"
        "    [infix (-b+sqrt(b*b-4*a*c)) / (2*a) infix] ;"
        "1 0 -1 quadratic-equation . ."
        "1.0\n-1.0"
    }
} ;

ARTICLE: "infix" "Infix notation"
"The " { $vocab-link "infix" } " vocabulary implements support for infix notation in Factor source code."
{ $subsections
    POSTPONE: [infix
    POSTPONE: INFIX::
}
"The usual infix math operators are supported:"
{ $list
    { $link + }
    { $link - }
    { $link * }
    { $link / }
    { { $snippet "**" } ", which is the infix operator for " { $link ^ } "." }
    { { $snippet "%" } ", which is the infix operator for " { $link mod } "." }
}
"The standard precedence rules apply: Grouping with parentheses before " { $snippet "*" } ", " { $snippet "/" } "and " { $snippet "%" } " before " { $snippet "+" } " and " { $snippet "-" } "."
{ $example
    "USE: infix"
    "[infix 5-40/10*2 infix] ."
    "-3"
}
$nl
"You can call Factor words in infix expressions just as you would in C. There are some restrictions on which words are legal to use though:"
{ $list
    "The word must return exactly one value."
    "The word name must consist of the letters a-z, A-Z, _ or 0-9, and the first character can't be a number."
}
{ $example
    "USING: infix locals math.functions ;"
    ":: binary_entropy ( p -- h )"
    "    [infix -(p*log(p) + (1-p)*log(1-p)) / log(2) infix] ;"
    "[infix binary_entropy( sqrt(0.25) ) infix] ."
    "1.0"
}
$nl
"You can access " { $vocab-link "sequences" } " inside infix expressions with the familiar " { $snippet "seq[index]" } " notation."
{ $example
    "USING: arrays locals infix ;"
    "[let { 1 2 3 4 } :> myarr [infix myarr[4/2]*3 infix] ] ."
    "9"
}
$nl
"You can create sub-" { $vocab-link "sequences" } " inside infix expressions using " { $snippet "seq[from:to]" } " notation."
{ $example
    "USING: arrays locals infix ;"
    "[let \"foobar\" :> s [infix s[0:3] infix] ] ."
    "\"foo\""
}
$nl
"Additionally, you can step through " { $vocab-link "sequences" } " with " { $snippet "seq[from:to:step]" } " notation."
{ $example
    "USING: arrays locals infix ;"
    "[let \"reverse\" :> s [infix s[::-1] infix] ] ."
    "\"esrever\""
}
{ $example
    "USING: arrays locals infix ;"
    "[let \"0123456789\" :> s [infix s[::2] infix] ] ."
    "\"02468\""
}
;

ABOUT: "infix"
