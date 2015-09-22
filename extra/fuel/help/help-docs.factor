USING: fuel.help.private help.markup help.syntax strings ;
IN: fuel.help

HELP: fuel-find-word
{ $values { "name" string } { "word/f" "word or f" } }
{ $description "Prefer to use search which takes the execution context into account. If that fails, fall back on a search of all words." } ;
