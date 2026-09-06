USING: assocs help.markup help.syntax ;
IN: stack-checker.branches

HELP: collect-variables
{ $values { "hash" assoc } }
{ $description "Gathers branch inference state into a hash, including the effect of the branch quotation itself. Unbalanced-branch diagnostics use this local effect, excluding the selector and untouched caller values." } ;
