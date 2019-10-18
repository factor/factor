USING: help.markup help.syntax math strings ;
IN: math.text.english

HELP: number>text
{ $values { "n" integer } { "str" string } }
{ $description "Converts an integer to a text string representation in English, including appropriate punctuation and conjunctions." }
{ $examples { $example "USING: math.text.english prettyprint ;" "12345 number>text ." "\"twelve thousand, three hundred and forty-five\"" } } ;
