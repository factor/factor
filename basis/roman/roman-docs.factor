! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;
IN: roman

HELP: >roman
{ $values { "n" "an integer" } { "str" "a string" } }
{ $description "Converts a number to its lower-case Roman Numeral equivalent." }
{ $notes "The range for this word is 1-3999, inclusive." }
{ $examples 
    { $example "USING: io roman ;"
               "56 >roman print"
               "lvi"
    }
} ;

HELP: >ROMAN
{ $values { "n" "an integer" } { "str" "a string" } }
{ $description "Converts a number to its upper-case Roman numeral equivalent." }
{ $notes "The range for this word is 1-3999, inclusive." }
{ $examples 
    { $example "USING: io roman ;"
               "56 >ROMAN print"
               "LVI"
    }
} ;

HELP: roman>
{ $values { "str" "a string" } { "n" "an integer" } }
{ $description "Converts a Roman numeral to an integer." }
{ $notes "The range for this word is i-mmmcmxcix, inclusive." }
{ $examples 
    { $example "USING: prettyprint roman ;"
               "\"lvi\" roman> ."
               "56"
    }
} ;

{ >roman >ROMAN roman> } related-words

HELP: roman+
{ $values { "string" string } { "string" string } { "string" string } }
{ $description "Adds two Roman numerals." }
{ $examples 
    { $example "USING: io roman ;"
               "\"v\" \"v\" roman+ print"
               "x"
    }
} ;

HELP: roman-
{ $values { "string" string } { "string" string } { "string" string } }
{ $description "Subtracts two Roman numerals." }
{ $examples 
    { $example "USING: io roman ;"
               "\"x\" \"v\" roman- print"
               "v"
    }
} ;

{ roman+ roman- } related-words

HELP: roman*
{ $values { "string" string } { "string" string } { "string" string } }
{ $description "Multiplies two Roman numerals." }
{ $examples 
    { $example "USING: io roman ;"
        "\"ii\" \"iii\" roman* print"
        "vi"
    }
} ;

HELP: roman/i
{ $values { "string" string } { "string" string } { "string" string } }
{ $description "Computes the integer division of two Roman numerals." }
{ $examples 
    { $example "USING: io roman ;"
        "\"v\" \"iv\" roman/i print"
        "i"
    }
} ;

HELP: roman/mod
{ $values { "string" string } { "string" string } { "string" string } { "string" string } }
{ $description "Computes the quotient and remainder of two Roman numerals." }
{ $examples 
    { $example "USING: kernel io roman ;"
        "\"v\" \"iv\" roman/mod [ print ] bi@"
        "i\ni"
    }
} ;

{ roman* roman/i roman/mod } related-words

HELP: ROMAN:
{ $description "A parsing word that reads the next token and converts it to an integer." }
{ $examples 
    { $example "USING: prettyprint roman ;"
               "ROMAN: v ."
               "5"
    }
} ;

ARTICLE: "roman" "Roman numerals"
"The " { $vocab-link "roman" } " vocabulary can convert numbers to and from the Roman numeral system and can perform arithmetic given Roman numerals as input." $nl
"A parsing word for literal Roman numerals:"
{ $subsection POSTPONE: ROMAN: }
"Converting to Roman numerals:"
{ $subsection >roman }
{ $subsection >ROMAN }
"Converting Roman numerals to integers:"
{ $subsection roman> }
"Roman numeral arithmetic:"
{ $subsection roman+ }
{ $subsection roman- }
{ $subsection roman* }
{ $subsection roman/i }
{ $subsection roman/mod } ;

ABOUT: "roman"
