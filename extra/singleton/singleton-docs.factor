USING: help.markup help.syntax ;
IN: singleton

HELP: SINGLETON:
{ $syntax "SINGLETON: class"
} { $values
    { "class" "a new tuple class to define" }
} { $description
    "Defines a new tuple class with membership predicate name? and a default empty constructor that is the class name itself."
} { $examples
    { $example "SINGLETON: foo\nfoo ." "T{ foo f }" }
} { $see-also
    POSTPONE: TUPLE:
} ;
