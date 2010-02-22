! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings words vocabs sequences ;
IN: tools.scaffold

HELP: developer-name
{ $description "Set this symbol to hold your name so that the scaffold tools can generate the correct file header for copyright. Setting this variable in your .factor-boot-rc file is recommended." }
{ $code "USING: namespaces tools.scaffold ;\n\"Stacky Guy\" developer-name set-global" } ;

HELP: help.
{ $values
     { "word" word } }
{ $description "Prints out scaffold help markup for a given word." } ;

HELP: scaffold-help
{ $values { "vocab" vocab } }
{ $description "Takes an existing vocabulary and creates a help file with scaffolded help for each word. This word only works if no help file yet exists." } ;

HELP: scaffold-undocumented
{ $values
     { "string" string } }
{ $description "Prints scaffolding documenation for undocumented words in a vocabuary except for automatically generated class predicates." } ;

{ scaffold-help scaffold-undocumented } related-words

HELP: scaffold-authors
{ $values
    { "vocab" "a vocabulary specifier" }
}
{ $description "Creates an authors.txt file using the value in " { $link developer-name } ". This word only works if no authors.txt file yet exists." } ;

HELP: scaffold-summary
{ $values
    { "vocab" "a vocabulary specifier" } { "summary" string }
}
{ $description "Creates a summary.txt file with the given summary. This word only works if no summary.txt file yet exists." } ;

HELP: scaffold-tags
{ $values
    { "vocab" "a vocabulary specifier" } { "tags" string }
}
{ $description "Creates a tags.txt file with the given tags. This word only works if no tags.txt file yet exists." } ;

HELP: scaffold-tests
{ $values
    { "vocab" "a vocabulary specifier" }
}
{ $description "Takes an existing vocabulary and creates an empty tests file help for each word. This word only works if no tests file yet exists." } ;

HELP: scaffold-vocab
{ $values
     { "vocab-root" "a vocabulary root string" } { "string" string } }
{ $description "Creates a directory in the given root for a new vocabulary and adds a main .factor file and an authors.txt file." } ;

HELP: scaffold-emacs
{ $description "Touches the .emacs file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-factor-boot-rc
{ $description "Touches the .factor-boot-rc file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-factor-rc
{ $description "Touches the .factor-rc file in your home directory and provides a clickable link to open it in an editor." } ;

HELP: scaffold-rc
{ $values
     { "path" "a pathname string" }
}
{ $description "Touches the given path in your home directory and provides a clickable link to open it in an editor." } ;

HELP: using
{ $description "Stores the vocabularies that are pulled into the documentation file from looking up the stack effect types." } ;

ARTICLE: "tools.scaffold" "Scaffold tool"
"Scaffold setup:"
{ $subsections developer-name }
"Generate new vocabs:"
{ $subsections scaffold-vocab }
"Generate help scaffolding:"
{ $subsections
    scaffold-help
    scaffold-undocumented
    help.
}
"Types that are unrecognized by the scaffold generator will be of type " { $link null } ". The developer should change these to strings that describe the stack effect names instead." $nl
"Scaffolding a configuration file:"
{ $subsections
    scaffold-rc
    scaffold-factor-boot-rc
    scaffold-factor-rc
    scaffold-emacs
}
;

ABOUT: "tools.scaffold"
