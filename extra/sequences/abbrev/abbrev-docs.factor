! Copyright (C) 2009 Maximilian Lupke.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax sequences ;
IN: sequences.abbrev

HELP: abbrev
{ $values
    { "seqs" sequence }
    { "assoc" assoc }
}
{ $description "Calculates an assoc of { prefix sequence } pairs with prefix being an prefix of each element of sequence for each element in " { $snippet "seqs" } "." } ;

HELP: unique-abbrev
{ $values
    { "seqs" sequence }
    { "assoc" assoc }
}
{ $description "Calculates an assoc of { prefix { sequence } } pairs with prefix being an unambiguous prefix of sequence in seqs." } ;

ARTICLE: "sequences.abbrev" "Examples of abbrev usage"
"It is probably easiest to just run examples to understand abbrev."
{ $code
    "{ \"hello\" \"help\" } abbrev"
    "{ \"hello\" \"help\" } unique-abbrev"
}
;

ABOUT: "sequences.abbrev"
