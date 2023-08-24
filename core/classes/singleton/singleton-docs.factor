USING: help.markup help.syntax ;
IN: classes.singleton

ARTICLE: "singletons" "Singleton classes"
"A singleton is a class with only one instance and with no state."
{ $subsections
    POSTPONE: SINGLETON:
    POSTPONE: SINGLETONS:
    define-singleton-class
}
"The set of all singleton classes is itself a class:"
{ $subsections
    singleton-class?
    singleton-class
} ;

HELP: define-singleton-class
{ $values { "word" "a new word" } }
{ $description
    "Defines a singleton class. This is the run-time equivalent of " { $link POSTPONE: SINGLETON: } "." } ;

{ POSTPONE: SINGLETON: define-singleton-class } related-words

HELP: singleton-class
{ $class-description "The class of singleton classes." } ;

ABOUT: "singletons"
