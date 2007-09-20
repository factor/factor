USING: inference.stack help.syntax help.markup ;

HELP: shuffle
{ $values { "stack" "a sequence" } { "shuffle" shuffle } { "newstack" "a new sequence" } }
{ $description "Applies a stack shuffle pattern to a stack." }
{ $errors "Throws an error if the input stack contains insufficient elements." } ;

HELP: shuffle-stacks
{ $values { "shuffle" "an instance of " { $link shuffle } } }
{ $description "Applies a stack shuffle pattern to the inference stacks." }
{ $errors "Throws an error if the stacks contain insufficient elements." } ;
