USING: help.markup help.syntax ;
IN: math.text.french

HELP: number>text
{ $values { "n" "an integer" } { "str" "a string" } }
{ $description "Return the a string describing " { $snippet "n" } " in French. Numbers with absolute value equal to or greater than 10^12 will be returned using their numeric representation." } ;
