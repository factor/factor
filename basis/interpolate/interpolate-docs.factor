USING: help.markup help.syntax math strings ;
IN: interpolate

HELP: ninterpolate
{ $values { "str" string } { "n" integer } }
{ $description "Assigns stack arguments to numbered variables for string interpolation." }
{ $examples
    { $example "USING: interpolate ;" "\"Bob\" \"Alice\" \"Hi ${0}, it's ${1}.\" 2 ninterpolate" "Hi Bob, it's Alice." }
}
{ $see-also interpolate } ;
