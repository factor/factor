USING: help.syntax help.markup kernel prettyprint sequences ;
IN: tuples.lib

HELP: >tuple<
{ $values { "class" "a tuple class" } }
{ $description "Explodes the tuple so that tuple slots are on the stack in the order listed in the tuple." }
{ $example
    "TUPLE: foo a b c ;"
    "1 2 3 \\ foo construct-boa \\ foo >tuple< .s"
    "1\n2\n3"
}
{ $notes "Words using " { $snippet ">tuple<" } " may be compiled." }
{ $see-also >tuple*< } ;

HELP: >tuple*<
{ $values { "class" "a tuple class" } }
{ $description "Explodes the tuple so that tuple slots ending with '*' are on the stack in the order listed in the tuple." }
{ $example
    "TUPLE: foo a bb* ccc dddd* ;"
    "1 2 3 4 \\ foo construct-boa \\ foo >tuple*< .s"
    "2\n4"
}
{ $notes "Words using " { $snippet ">tuple*<" } " may be compiled." }
{ $see-also >tuple< } ;

