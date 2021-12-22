USING: help.markup help.syntax vm quotations tools.dispatch ;

HELP: last-dispatch-stats
{ $var-description "A " { $link dispatch-statistics } " instance, set by " { $link collect-dispatch-stats } "." } ;

HELP: dispatch-stats.
{ $description "Prints method dispatch statistics from the last call to " { $link collect-dispatch-stats } "." } ;
