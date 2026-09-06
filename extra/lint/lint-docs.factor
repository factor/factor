USING: help.markup help.syntax kernel words ;
IN: lint

HELP: unused-recursive?
{ $values { "word" word } { "?" boolean } }
{ $description "Checks whether an " { $snippet "inline recursive" } " word has no recursive calls to itself in its inferred body. This includes calls through inline helpers and macro expansions. Words whose bodies cannot be inferred without additional inputs are not reported."
    $nl
    "The lint commands report this as an advisory. The declaration remains legal, and no word properties are changed." } ;
