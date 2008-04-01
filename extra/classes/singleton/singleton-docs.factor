USING: help.markup help.syntax kernel words ;
IN: classes.singleton

HELP: SINGLETON:
{ $syntax "SINGLETON: class"
} { $values
    { "class" "a new singleton to define" }
} { $description
    "Defines a new predicate class whose superclass is " { $link word } ".  Only one instance of a singleton may exist because classes are " { $link eq? } " to themselves.  Methods may be defined on a singleton."
} { $examples
    { $example "USING: singleton kernel io ;" "SINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} { $see-also
    POSTPONE: PREDICATE:
} ;
