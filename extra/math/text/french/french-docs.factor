USING: help.markup help.syntax math strings ;
IN: math.text.french

HELP: number>text
{ $values { "n" integer } { "str" string } }
{ $description "Return the a string describing " { $snippet "n" } " in French. Numbers with absolute value equal to or greater than 10^12 will be returned using their numeric representation." } ;
