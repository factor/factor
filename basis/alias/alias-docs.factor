! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words help.markup help.syntax ;
IN: alias

HELP: ALIAS:
{ $syntax "ALIAS: new-word existing-word" }
{ $values { "new-word" word } { "existing-word" word } }
{ $description "Creates a " { $snippet "new" } " inlined word that calls the " { $snippet "existing" } " word." }
{ $examples
    { $example "USING: alias prettyprint sequences ;"
               "IN: alias.test"
               "ALIAS: sequence-nth nth"
               "0 { 10 20 30 } sequence-nth ."
               "10"
    }
} ;

ARTICLE: "alias" "Alias"
"The " { $vocab-link "alias" } " vocabulary implements a way to make many different names for the same word. Although creating new names for words is generally frowned upon, aliases are useful for the Win32 API and other cases where words need to be renamed for symmetry." $nl 
"Make a new word that aliases another word:"
{ $subsection define-alias }
"Make an alias at parse-time:"
{ $subsection POSTPONE: ALIAS: } ;

ABOUT: "alias"
