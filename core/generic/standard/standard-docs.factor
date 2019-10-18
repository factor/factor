USING: generic generic.single help.markup help.syntax sequences math
math.parser effects ;
IN: generic.standard

HELP: standard-combination
{ $class-description
    "Performs standard method combination."
    $nl
    "Generic words using the standard method combination dispatch on the class of the object at the given stack position, where 0 is the top of the stack, 1 is the object underneath, and 2 is the next one under that. A " { $link no-method } " error is thrown if no suitable method is defined on the class."
}
{ $examples
    "A generic word for append strings and characters to a sequence, dispatching on the object underneath the top of the stack:"
    { $code
        "GENERIC# build-string 1 ( elt str -- )"
        "M: string build-string swap push-all ;"
        "M: integer build-string push ;"
    }
} ;

HELP: define-simple-generic
{ $values { "word" "a word" } { "effect" effect } }
{ $description "Defines a generic word with the " { $link standard-combination } " method combination and a dispatch position of 0." } ;