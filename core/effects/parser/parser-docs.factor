USING: effects effects.parser help.markup help.syntax strings ;
IN: effects.parser+docs

HELP: parse-effect
{ $values { "end" string } { "effect" "an instance of " { $link effect } } }
{ $description "Parses a stack effect from the current input line." }
{ $examples "This word is used by " { $link POSTPONE: ( } " to parse stack effect declarations." }
$parsing-note ;
