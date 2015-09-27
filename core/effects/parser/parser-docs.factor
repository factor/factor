IN: effects.parser
USING: strings effects help.markup help.syntax ;

HELP: parse-effect
{ $values { "end" string } { "effect" "an instance of " { $link effect } } }
{ $description "Parses a stack effect from the current input line." }
{ $examples "This word is used by " { $link POSTPONE: ( } " to parse stack effect declarations." }
$parsing-note ;
