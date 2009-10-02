! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel words ;
IN: prettyprint.stylesheet

HELP: effect-style
{ $values
    { "effect" "an effect" }
    { "style" "a style assoc" }
}
{ $description "The styling hook for stack effects" } ;

HELP: string-style
{ $values
    { "str" "a string" }
    { "style" "a style assoc" }
}
{ $description "The styling hook for string literals" } ;

HELP: vocab-style
{ $values
    { "vocab" "a vocabulary specifier" }
    { "style" "a style assoc" }
}
{ $description "The styling hook for vocab names" } ;

HELP: word-style
{ $values
    { "word" "a word" }
    { "style" "a style assoc" }
}
{ $description "The styling hook for word names" } ;

ARTICLE: "prettyprint.stylesheet" "Prettyprinter Formatted Output"
{ $vocab-link "prettyprint.stylesheet" }
$nl
"Control the way that the prettyprinter formats output based on object type. These hooks form a basic \"syntax\" highlighting system."
{ $subsections
    word-style
    string-style
    vocab-style
    effect-style
}
;

ABOUT: "prettyprint.stylesheet"
