USING: help.markup help.syntax inference.state ;

HELP: d-in
{ $var-description "During inference, holds the number of inputs which the quotation has been inferred to require so far." } ;

HELP: recursive-state
{ $var-description "During inference, holds an association list mapping words to labels." } ;

HELP: terminated?
{ $var-description "During inference, a flag set to " { $link t } " if the current control flow path unconditionally throws an error." } ;

