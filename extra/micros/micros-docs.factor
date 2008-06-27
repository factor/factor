IN: micros
USING: help.syntax help.markup kernel prettyprint sequences ;

HELP: micros
{ $values { "n" "an integer" } } 
{ $description "Outputs the number of microseconds ellapsed since midnight January 1, 1970"
} ;

    
HELP: micro-time
{ $values { "quot" "a quot" }
          { "n" "an integer" } }
{ $description "executes the quotation and pushes the number of microseconds taken onto the stack"
} ;
