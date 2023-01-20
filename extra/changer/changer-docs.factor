! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations strings ;
IN: changer

HELP: change:
{ $description "Syntax word for applying a quotation to a tuple slot." }
{ $examples
    "Change a tuple slot:"
    { $example
        "USING: prettyprint changer kernel math ;"
        "IN: changer"
        "TUPLE: nightclub count ;"
        "T{ nightclub f 0 } [ 3 + ] change: count ."
        "T{ nightclub { count 3 } }"
    }
} ;

HELP: inline-changer
{ $values
    { "name" string }
    { "quot'" quotation }
}
{ $description "A macro that takes a slot name and applies the quotation to a slot of a tuple." } ;

ARTICLE: "changer" "Changer syntax"
"The " { $vocab-link "changer" } " vocabulary defines one word to change the values of a slot of tuple objects."
$nl
"Syntax word to change tuple slots:"
{ $subsections
    POSTPONE: change:
}
"Macro to implement " { $link POSTPONE: change: } ":"
{ $subsections
    inline-changer
} ;

ABOUT: "changer"
