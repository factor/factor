USING: assocs effects help.markup help.syntax kernel ;
IN: stack-checker.row-polymorphism

HELP: check-variables
{ $values { "vars" assoc } { "declared" effect } { "actual" effect } { "?" boolean } }
{ $description "Checks an inferred effect against a declaration, accumulating shared row constraints in " { $snippet "vars" } ". A shallow effect may be extended with an untouched stack prefix. Related rows grow together, preserving earlier constraints; a monomorphic side fixes the size of its connected rows." }
{ $notes "Start each independent group of declarations with an empty association. The stored bindings are internal to the stack checker." } ;
