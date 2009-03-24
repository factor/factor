USING: generic help.markup help.syntax sequences math
math.parser effects ;
IN: generic.standard

HELP: no-method
{ $values { "object" "an object" } { "generic" "a generic word" } }
{ $description "Throws a " { $link no-method } " error." }
{ $error-description "Thrown by the " { $snippet "generic" } " word to indicate it does not have a method for the class of " { $snippet "object" } "." } ;

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

HELP: hook-combination
{ $class-description
    "Performs hook method combination . See " { $link POSTPONE: HOOK: } "."
} ;

HELP: define-simple-generic
{ $values { "word" "a word" } { "effect" effect } }
{ $description "Defines a generic word with the " { $link standard-combination } " method combination and a dispatch position of 0." } ;

{ standard-combination hook-combination } related-words

HELP: inconsistent-next-method
{ $error-description "Thrown by " { $link POSTPONE: call-next-method } " if the values on the stack are not compatible with the current method." }
{ $examples
    "The following code throws this error:"
    { $code
        "GENERIC: error-test ( object -- )"
        ""
        "M: string error-test print ;"
        ""
        "M: integer error-test number>string call-next-method ;"
        ""
        "123 error-test"
    }
    "This results in the method on " { $link integer } " being called, which then passes a string to " { $link POSTPONE: call-next-method } ". However, this fails because the string is not compatible with the current method."
    $nl
    "This usually indicates programmer error; if the intention above was to call the string method on the result of " { $link number>string } ", the code should be rewritten as follows:"
    { $code "M: integer error-test number>string error-test ;" }
} ;
