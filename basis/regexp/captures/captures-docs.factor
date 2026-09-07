USING: help.markup help.syntax kernel sequences strings ;
IN: regexp.captures

HELP: regexp-match
{ $class-description "A capture result with a " { $snippet "groups" } " array and a " { $snippet "names" } " association mapping names to group numbers. Group zero is the whole match. Each group is a slice or " { $link f } "." } ;

HELP: duplicate-capture-name
{ $values { "name" string } }
{ $error-description "A capturing group name occurs more than once in the regular expression." } ;

HELP: unknown-capture-group
{ $values { "group" "a group number or name" } }
{ $error-description "A capture was requested with an unknown name, a non-integer index, or an index outside the result's group array." } ;

HELP: inconsistent-capture-match
{ $error-description "The capture automaton could not reproduce the whole match selected by the DFA. This indicates an internal regular expression error." } ;

HELP: compile-captures
{ $values { "ast" "a regexp syntax tree" } { "options" "regexp options" } { "code" "a capture program" } }
{ $description "Compiles an ordered NFA for capture extraction. This is an implementation word used by the main regexp vocabulary." } ;

HELP: captures-at
{ $values { "start" "a character index" } { "end" "an exclusive character index" } { "string" string } { "code" "a capture program" } { "match" regexp-match } }
{ $description "Extracts captures within an already selected whole-match span. This is an implementation word used by the main regexp vocabulary." } ;
