USING: help.markup help.syntax math strings ;
IN: math.text.english

HELP: number>text
{ $values { "n" integer } { "str" string } }
{ $contract "Converts an integer to a text string representation in English, including appropriate punctuation and conjunctions." }
{ $examples { $example "USING: math.text.english prettyprint ;" "12345 number>text ." "\"twelve thousand, three hundred and forty-five\"" } } ;

HELP: ordinal-suffix
{ $values { "n" number } { "suffix" string } }
{ $description "Determine the ordinal suffix for the input number. Non-integral numbers get the ordinal suffix of their integral part." }
{ $examples
    { $example
        "USING: kernel math.parser math.text.english prettyprint sequences ;"
        "783 [ number>string ] [ ordinal-suffix ] bi append ."
        "\"783rd\""
    }
} ;
