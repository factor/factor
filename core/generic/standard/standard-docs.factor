USING: generic help.markup help.syntax sequences
generic.standard ;

HELP: no-method
{ $values { "object" "an object" } { "generic" "a generic word" } }
{ $description "Throws a " { $link no-method } " error." }
{ $error-description "Thrown by the " { $snippet "generic" } " word to indicate it does not have a method for the class of " { $snippet "object" } "." } ;

HELP: standard-combination
{ $class-description
    "Performs standard method combination."
    $nl
    "Generic words using the standard method combination dispatch on the class of the object at the given stack position, where 0 is the top of the stack, 1 is the object underneath, and 2 is the next one under that. If no suitable method is defined on the class of the dispatch object, the generic word is called on the dispatch object's delegate. If the delegate is " { $link f } ", an exception is thrown."
}
{ $examples
    "A generic word for append strings and characters to a sequence, dispatching on the object underneath the top of the stack:"
    { $code
        "G: build-string 1 standard-combination ;"
        "M: string build-string swap push-all ;"
        "M: integer build-string push ;"
    }
} ;

HELP: hook-combination
{ $class-description
    "Performs hook method combination . See " { $link POSTPONE: HOOK: } "."
} ;

HELP: define-simple-generic
{ $values { "word" "a word" } }
{ $description "Defines a generic word with the " { $link standard-combination } " method combination and a dispatch position of 0." } ;

{ standard-combination hook-combination } related-words
