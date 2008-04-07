USING: help.markup help.syntax kernel words ;
IN: classes.singleton

ARTICLE: "singletons" "Singleton classes"
"A singleton is a class with only one instance and with no state."
{ $subsection POSTPONE: SINGLETON: }
{ $subsection define-singleton-class }
"The set of all singleton classes is itself a class:"
{ $subsection singleton-class? }
{ $subsection singleton-class } ;

HELP: SINGLETON:
{ $syntax "SINGLETON: class" }
{ $values
    { "class" "a new singleton to define" }
}
{ $description
    "Defines a new singleton class. The class word itself is the sole instance of the singleton class."
}
{ $examples
    { $example "USING: classes.singleton kernel io ;" "SINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} ;

HELP: define-singleton-class
{ $values { "word" "a new word" } }
{ $description
    "Defines a singleton class. This is the run-time equivalent of " { $link POSTPONE: SINGLETON: } "." } ;

{ POSTPONE: SINGLETON: define-singleton-class } related-words

HELP: singleton-class
{ $class-description "The class of singleton classes." } ;

ABOUT: "singletons"
