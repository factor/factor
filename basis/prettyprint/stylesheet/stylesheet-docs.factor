! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings words ;
IN: prettyprint.stylesheet

HELP: effect-style
{ $values
    { "effect" "an effect" }
    { "style" "a style assoc" }
}
{ $description "The stylesheet for stack effects" } ;

HELP: string-style
{ $values
    { "str" string }
    { "style" "a style assoc" }
}
{ $description "The stylesheet for string literals" } ;

HELP: vocab-style
{ $values
    { "vocab" "a vocabulary specifier" }
    { "style" "a style assoc" }
}
{ $description "The stylesheet for vocab names" } ;

HELP: word-style
{ $values
    { "word" word }
    { "style" "a style assoc" }
}
{ $description "The stylesheet for word names" } ;

ARTICLE: "prettyprint.stylesheet" "Prettyprinter stylesheet"
"The " { $vocab-link "prettyprint.stylesheet" } " vocabulary defines variables which control the way that the prettyprinter formats output based on object type."
{ $subsections
    word-style
    string-style
    vocab-style
    effect-style
}
;

ABOUT: "prettyprint.stylesheet"
