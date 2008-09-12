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


