! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: qw

HELP: qw{
{ $syntax "qw{ lorem ipsum }" }
{ $description "Marks the beginning of a literal array of strings. Component strings are delimited by whitespace." }
{ $examples
{ $example "USING: prettyprint qw ;
qw{ a man a plan a canal panama } ."
"{ \"a\" \"man\" \"a\" \"plan\" \"a\" \"canal\" \"panama\" }" }
} ;

ARTICLE: "qw" "Quoted words"
"The " { $vocab-link "qw" } " vocabulary offers a shorthand syntax for arrays of single-word string literals." $nl
"Construct an array of strings:"
{ $subsections POSTPONE: qw{ } ;

ABOUT: "qw"
