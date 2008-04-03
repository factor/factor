USING: help.markup help.syntax kernel words ;
IN: classes.singleton

ARTICLE: "singletons" "Singleton classes"
"A singleton is a class with only one instance and with no state.  Methods may dispatch off of singleton classes."
{ $subsection POSTPONE: SINGLETON: }
{ $subsection define-singleton-class } ;

HELP: SINGLETON:
{ $syntax "SINGLETON: class"
} { $values
    { "class" "a new singleton to define" }
} { $description
    "Defines a new predicate class whose superclass is " { $link word } ".  Only one instance of a singleton may exist because classes are " { $link eq? } " to themselves.  Methods may be defined on a singleton."
} { $examples
    { $example "USING: classes.singleton kernel io ;" "SINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} { $see-also
    POSTPONE: PREDICATE:
} ;

HELP: define-singleton-class
{ $values { "word" "a new word" } }
{ $description
    "Defines a newly created word to be a singleton class." } ;

{ POSTPONE: SINGLETON: define-singleton-class } related-words

ABOUT: "singletons"
