! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings words ;
IN: tools.scaffold

HELP: developer-name
{ $description "Set this symbol to hold your name so that the scaffold tools can generate the correct file header for copyright. Setting this variable in your .factor-boot-rc file is recommended." }
{ $code "USING: namespaces tools.scaffold ;\n\"Stacky Guy\" developer-name set-global" } ;

HELP: help.
{ $values
     { "word" word } }
{ $description "Prints out scaffold help markup for a given word." } ;

HELP: scaffold-help
{ $values { "string" string } }
{ $description "Takes an existing vocabulary and creates a help file with scaffolded help for each word. This word only works if no help file yet exists." } ;

HELP: scaffold-undocumented
{ $values
     { "string" string } }
{ $description "Prints scaffolding documenation for undocumented words in a vocabuary except for automatically generated class predicates." } ;

{ scaffold-help scaffold-undocumented } related-words

HELP: scaffold-vocab
{ $values
     { "vocab-root" "a vocabulary root string" } { "string" string } }
{ $description "Creates a directory in the given root for a new vocabulary and adds a main .factor file, a tests file, and an authors.txt file." } ;

HELP: using
{ $description "Stores the vocabularies that are pulled into the documentation file from looking up the stack effect types." } ;

ARTICLE: "tools.scaffold" "Scaffold tool"
"Scaffold setup:"
{ $subsection developer-name }
"Generate new vocabs:"
{ $subsection scaffold-vocab }
"Generate help scaffolding:"
{ $subsection scaffold-help }
{ $subsection scaffold-undocumented }
{ $subsection help. }
"Types that are unrecognized by the scaffold generator will be of type " { $link null } ". The developer should change these to strings that describe the stack effect names instead."
;

ABOUT: "tools.scaffold"
