! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax multiline ;
IN: qw

HELP: qw{
{ $syntax "qw{ lorem ipsum }" }
{ $description "Marks the beginning of a literal array of strings. Component strings are delimited by whitespace." }
{ $examples
{ $unchecked-example "USING: prettyprint qw ;
qw{ pop quiz my hive of big wild ex tranny jocks } ."
"{ \"pop\" \"quiz\" \"my\" \"hive\" \"of\" \"big\" \"wild\" \"ex\" \"tranny\" \"jocks\" }" }
} ;

ARTICLE: "qw" "Quoted words"
"The " { $vocab-link "qw" } " vocabulary offers a shorthand syntax for arrays-of-strings literals." $nl
"Construct an array of strings:"
{ $subsections POSTPONE: qw{ } ;

ABOUT: "qw"
