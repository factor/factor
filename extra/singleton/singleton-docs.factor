USING: help.markup help.syntax kernel words ;
IN: singleton

HELP: SINGLETON:
{ $syntax "SINGLETON: class"
} { $values
    { "class" "a new singleton to define" }
} { $description
    "Defines a new predicate class whose superclass is " { $link word } ".  Only one instance of a singleton may exist because classes are " { $link eq? } " to themselves.  Methods may be defined on a singleton."
} { $examples
    { $example "SINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} { $see-also
    POSTPONE: PREDICATE:
} ;

HELP: SINGLETONS:
{ $syntax "SINGLETONS: classes... ;"
} { $values
    { "classes" "new singletons to define" }
} { $description
    "Defines a new singleton for each class in the list."
} { $examples
    { $example "SINGLETONS: foo bar baz ;" "" }
} { $see-also
    POSTPONE: SINGLETON:
} ;
